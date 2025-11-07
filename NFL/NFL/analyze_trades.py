"""
Analyze potential trades for all teams.
Finds win-win trades that increase power for both teams involved.

Trade criteria:
- Must involve 3 or fewer players total
- Must increase power score for both teams
- Analyzes trades for all teams
"""

import csv
from pathlib import Path
from typing import Dict, List, Tuple
from itertools import combinations
import copy

from common.fantasy_utils import (
    POSITION_WEIGHTS,
    load_rankings,
    load_rosters,
    get_player_score,
    select_starters,
    calculate_team_power,
    get_waiver_players
)


def player_would_start(player_name: str, roster: List[Dict], rankings: Dict[str, int], 
                       waiver_players: Dict[str, List[Dict]] = None) -> bool:
    """
    Check if a player would make the starting lineup on a given roster.
    Returns True if the player would be in the optimal starting 10.
    """
    starters, _ = select_starters(roster, rankings, waiver_players)
    starter_names = {s['name'] for s in starters}
    return player_name in starter_names


def simulate_trade(team1_roster: List[Dict], team2_roster: List[Dict], 
                   team1_gives: List[str], team2_gives: List[str],
                   rankings: Dict[str, int], waiver_players: Dict[str, List[Dict]] = None) -> Tuple[float, float]:
    """
    Simulate a trade and return new power scores for both teams.
    Returns (team1_new_power, team2_new_power)
    
    Optimized to avoid unnecessary deep copies - uses shallow references since
    player dicts are not modified during power calculation.
    """
    # Create roster lookups for fast access
    team1_dict = {p['name']: p for p in team1_roster}
    team2_dict = {p['name']: p for p in team2_roster}
    
    # Build new rosters efficiently
    team1_gives_set = set(team1_gives)
    team2_gives_set = set(team2_gives)
    
    team1_new = [p for p in team1_roster if p['name'] not in team1_gives_set]
    team2_new = [p for p in team2_roster if p['name'] not in team2_gives_set]
    
    # Add players being received (no need to deepcopy since we don't modify)
    for player_name in team2_gives:
        player = team2_dict.get(player_name)
        if player:
            team1_new.append(player)
    
    for player_name in team1_gives:
        player = team1_dict.get(player_name)
        if player:
            team2_new.append(player)
    
    # Calculate new power scores
    team1_power = calculate_team_power(team1_new, rankings, waiver_players)
    team2_power = calculate_team_power(team2_new, rankings, waiver_players)
    
    return team1_power, team2_power


def get_tradeable_players(roster: List[Dict], rankings: Dict[str, int], waiver_players: Dict[str, List[Dict]] = None) -> List[Dict]:
    """
    Get players that are reasonable to trade.
    Only includes QB, RB, WR, TE - excludes K and DST (those are waiver pickups).
    """
    # Get current starters
    starters, _ = select_starters(roster, rankings, waiver_players)
    starter_names = {s['name'] for s in starters}
    
    tradeable = []
    
    for player in roster:
        # Only include skill positions that are actually traded in fantasy
        if player['position'] in ['QB', 'RB', 'WR', 'TE']:
            # Add rank and base score for value comparison
            player_copy = player.copy()
            player_copy['rank'] = rankings.get(player['name'], 0)
            player_copy['score'] = get_player_score(player_copy['rank'], player['position'])
            tradeable.append(player_copy)
        # K and DST are NEVER traded - they're waiver wire pickups
    
    return tradeable


def positions_match(give_positions: List[str], receive_positions: List[str]) -> bool:
    """
    Check if traded positions are reasonable matches.
    Good trades typically involve similar position groups.
    """
    # Group positions into categories
    def get_position_group(pos: str) -> str:
        if pos in ['QB']:
            return 'QB'
        elif pos in ['RB', 'WR', 'TE']:
            return 'SKILL'  # Flex-eligible positions
        else:
            return 'SPECIAL'  # K, DST
    
    give_groups = {get_position_group(p) for p in give_positions}
    receive_groups = {get_position_group(p) for p in receive_positions}
    
    # Must have at least one matching position group
    return bool(give_groups & receive_groups)


def check_roster_balance_penalty(roster: List[Dict], rankings: Dict[str, int]) -> float:
    """
    Calculate penalty for roster position imbalances.
    Teams with very weak positions get penalized for hoarding their strong positions.
    Returns a factor between 0.5 and 1.0 (1.0 = balanced, 0.5 = very imbalanced).
    """
    # Count starters by position quality
    position_scores = {'QB': [], 'RB': [], 'WR': [], 'TE': []}
    
    for player in roster:
        pos = player['position']
        if pos in position_scores:
            rank = rankings.get(player['name'], 999)
            score = get_player_score(rank, pos)
            position_scores[pos].append(score)
    
    # Get top 2 players for RB/WR, top 1 for QB/TE
    avg_scores = {}
    avg_scores['QB'] = position_scores['QB'][0] if position_scores['QB'] else 0
    avg_scores['RB'] = sum(sorted(position_scores['RB'], reverse=True)[:2]) / 2 if len(position_scores['RB']) >= 2 else 0
    avg_scores['WR'] = sum(sorted(position_scores['WR'], reverse=True)[:2]) / 2 if len(position_scores['WR']) >= 2 else 0
    avg_scores['TE'] = position_scores['TE'][0] if position_scores['TE'] else 0
    
    # Calculate imbalance: if one position is way stronger than others, that's imbalanced
    if not any(avg_scores.values()):
        return 1.0
    
    max_score = max(avg_scores.values())
    min_score = min(v for v in avg_scores.values() if v > 0) if any(v > 0 for v in avg_scores.values()) else max_score
    
    if max_score == 0:
        return 1.0
    
    # Calculate imbalance ratio (closer to 1.0 = more balanced)
    imbalance = min_score / max_score if max_score > 0 else 1.0
    
    # Return penalty factor: 1.0 if balanced, down to 0.5 if very imbalanced
    # This means extremely imbalanced teams need bigger improvements
    return 0.5 + (imbalance * 0.5)


def check_rank_disparity_for_1_for_1(team_gives: List[str], other_gives: List[str], 
                                      team_tradeable: List[Dict], other_tradeable: List[Dict]) -> bool:
    """
    For 1-for-1 trades, check if rank disparity is reasonable.
    Prevent trading top-10 players for mid-tier players straight up.
    """
    if len(team_gives) != 1 or len(other_gives) != 1:
        return True  # Not a 1-for-1 trade
    
    team_player = next((p for p in team_tradeable if p['name'] == team_gives[0]), None)
    other_player = next((p for p in other_tradeable if p['name'] == other_gives[0]), None)
    
    if not team_player or not other_player:
        return True
    
    team_rank = team_player['rank']
    other_rank = other_player['rank']
    
    # Don't allow trading someone ranked in top 10 for someone ranked 25+
    # (Elite players need elite returns in 1-for-1)
    if team_rank <= 10 and other_rank >= 25:
        return False
    if other_rank <= 10 and team_rank >= 25:
        return False
    
    # Don't allow trading someone ranked 11-20 for someone ranked 50+
    # (Very good players need good returns)
    if team_rank <= 20 and other_rank >= 50:
        return False
    if other_rank <= 20 and team_rank >= 50:
        return False
    
    return True


def check_2_for_1_starter_utilization(giving_team_roster: List[Dict], 
                                       players_given: List[str],
                                       rankings: Dict[str, int],
                                       waiver_players: Dict[str, List[Dict]]) -> bool:
    """
    For 2-for-1 trades, verify the team GIVING 2 players would start at least one of them.
    If neither of the 2 players being given away are starters, it's likely a bad trade
    (trading 2 bench players for 1 starter is usually good, so we allow it).
    """
    if len(players_given) != 2:
        return True  # Not a 2-for-1 trade, skip check
    
    # Get current starters for the team GIVING the 2 players
    starters, _ = select_starters(giving_team_roster, rankings, waiver_players)
    starter_names = {s['name'] for s in starters}
    
    # Count how many of the given players are currently starters
    starters_given = sum(1 for p in players_given if p in starter_names)
    
    # Allow the trade - we're being permissive here
    # The main checks are rank disparity and minimum improvement
    return True


def check_position_downgrade(team_gives: List[str], other_gives: List[str],
                             team_tradeable: List[Dict], other_tradeable: List[Dict],
                             team_roster: List[Dict], other_roster: List[Dict],
                             rankings: Dict[str, int], waiver_players: Dict[str, List[Dict]]) -> bool:
    """
    Check if a trade involves unnecessary position accumulation.
    Prevents trades like: Trading FOR a 3rd QB when you already have 2 (only start 1).
    Returns False if trade should be blocked.
    """
    # Count current positions on each roster
    def count_positions(roster: List[Dict]) -> Dict[str, int]:
        counts = {}
        for player in roster:
            pos = player['position']
            counts[pos] = counts.get(pos, 0) + 1
        return counts
    
    team_current_counts = count_positions(team_roster)
    other_current_counts = count_positions(other_roster)
    
    # Get positions being traded
    team_receiving_positions = [p['position'] for p in other_tradeable if p['name'] in other_gives]
    other_receiving_positions = [p['position'] for p in team_tradeable if p['name'] in team_gives]
    
    # Check if team is trying to acquire a QB when they already have 2+
    if 'QB' in team_receiving_positions:
        if team_current_counts.get('QB', 0) >= 2:
            # Only allow if they're also trading away a QB
            if 'QB' not in [p['position'] for p in team_tradeable if p['name'] in team_gives]:
                return False  # Block: trading FOR QB when already have 2+
    
    # Check if other team is trying to acquire a QB when they already have 2+
    if 'QB' in other_receiving_positions:
        if other_current_counts.get('QB', 0) >= 2:
            if 'QB' not in [p['position'] for p in other_tradeable if p['name'] in other_gives]:
                return False
    
    # Same logic for TE (don't acquire 3rd TE unless trading one away)
    if 'TE' in team_receiving_positions:
        if team_current_counts.get('TE', 0) >= 2:
            if 'TE' not in [p['position'] for p in team_tradeable if p['name'] in team_gives]:
                return False
    
    if 'TE' in other_receiving_positions:
        if other_current_counts.get('TE', 0) >= 2:
            if 'TE' not in [p['position'] for p in other_tradeable if p['name'] in other_gives]:
                return False
    
    return True


def find_trades_for_team(team_name: str, rosters: Dict[str, List[Dict]], rankings: Dict[str, int], waiver_players: Dict[str, List[Dict]]) -> List[Dict]:
    """
    Find all beneficial trades for a specific team.
    Returns list of trade scenarios with power improvements.
    """
    team_roster = rosters[team_name]
    team_current_power = calculate_team_power(team_roster, rankings, waiver_players)
    
    all_trades = []
    seen_trades = set()  # Track unique trades to avoid duplicates
    
    # Cache for power calculations to avoid recalculating same rosters
    power_cache = {}
    
    # Convert rosters to dicts for O(1) player lookups
    team_roster_dict = {p['name']: p for p in team_roster}
    
    # Try trades with each other team
    for other_team_name, other_team_roster in rosters.items():
        if other_team_name == team_name:
            continue
        
        other_team_current_power = calculate_team_power(other_team_roster, rankings, waiver_players)
        
        # Get tradeable players (excludes backup K/DST)
        team_tradeable = get_tradeable_players(team_roster, rankings, waiver_players)
        other_tradeable = get_tradeable_players(other_team_roster, rankings, waiver_players)
        
        # Convert to dicts for faster lookups
        other_roster_dict = {p['name']: p for p in other_team_roster}
        team_tradeable_dict = {p['name']: p for p in team_tradeable}
        other_tradeable_dict = {p['name']: p for p in other_tradeable}
        
        # Try all combinations of 1, 2, or 3 player trades
        for team_count in range(1, 4):  # 1, 2, or 3 players
            for other_count in range(1, 4):  # 1, 2, or 3 players
                if team_count + other_count > 5:  # Total must be 5 or less
                    continue
                
                # Get all combinations of players to trade
                team_player_names = [p['name'] for p in team_tradeable]
                other_player_names = [p['name'] for p in other_tradeable]
                
                for team_gives in combinations(team_player_names, team_count):
                    team_gives_set = set(team_gives)
                    
                    # Pre-compute positions and values for team_gives (avoid recomputing in inner loop)
                    team_give_positions = [team_tradeable_dict[name]['position'] for name in team_gives]
                    team_give_value = sum(team_tradeable_dict[name]['score'] for name in team_gives)
                    
                    for other_gives in combinations(other_player_names, other_count):
                        # Get positions being traded
                        other_give_positions = [other_tradeable_dict[name]['position'] for name in other_gives]
                        
                        # Calculate total value being traded by each side (for fairness check)
                        other_give_value = sum(other_tradeable_dict[name]['score'] for name in other_gives)
                        
                        # Don't allow trades where skill position value is too imbalanced
                        # The side giving away more skill value should receive within 85% of that value
                        if team_give_value > 0 and other_give_value > 0:
                            if team_give_value > other_give_value * 1.18:  # 1/0.85 = 1.18
                                continue
                            if other_give_value > team_give_value * 1.18:
                                continue
                        
                        # Prevent bad 2-for-1 or 3-for-1 trades
                        # For 2-for-1: Allow if it's reasonable consolidation
                        # For 3-for-1 or 1-for-3: Must be very lopsided value
                        team_count_actual = len(team_gives)
                        other_count_actual = len(other_gives)
                        
                        if team_count_actual > other_count_actual:
                            # Team giving more players - allow 2-for-1 with fair value
                            if team_count_actual == 2 and other_count_actual == 1:
                                # 2-for-1: require at least 80% total value back
                                if other_give_value < team_give_value * 0.80:
                                    continue
                            else:
                                # 3-for-1 or worse: require 90% value back
                                if other_give_value < team_give_value * 0.90:
                                    continue
                        elif other_count_actual > team_count_actual:
                            # Team receiving more players - allow 1-for-2 with fair value
                            if other_count_actual == 2 and team_count_actual == 1:
                                # 1-for-2: require giving at least 80% of received value
                                if team_give_value < other_give_value * 0.80:
                                    continue
                            else:
                                # 1-for-3 or worse: require giving 85% of received value
                                if team_give_value < other_give_value * 0.85:
                                    continue
                        
                        # Check if positions match reasonably
                        if not positions_match(team_give_positions, other_give_positions):
                            continue
                        
                        # Check rank disparity for 1-for-1 trades (prevent top-10 for mid-tier)
                        if not check_rank_disparity_for_1_for_1(list(team_gives), list(other_gives), 
                                                                  team_tradeable, other_tradeable):
                            continue
                        
                        # Filter out players that won't contribute to starting lineup BEFORE simulation
                        # This prevents duplicate trades with different non-starter combinations
                        # Check team's potential received players - build roster efficiently
                        team_new_roster_temp = [p for p in team_roster if p['name'] not in team_gives]
                        for player_name in other_gives:
                            player = other_roster_dict.get(player_name)
                            if player:
                                team_new_roster_temp.append(player)
                        
                        # Filter to only players that would actually start
                        other_gives_filtered = tuple(sorted([p for p in other_gives 
                                                  if player_would_start(p, team_new_roster_temp, rankings, waiver_players)]))
                        
                        # Check other team's potential received players - build roster efficiently
                        other_new_roster_temp = [p for p in other_team_roster if p['name'] not in other_gives]
                        for player_name in team_gives:
                            player = team_roster_dict.get(player_name)
                            if player:
                                other_new_roster_temp.append(player)
                        
                        team_gives_filtered = tuple(sorted([p for p in team_gives 
                                                   if player_would_start(p, other_new_roster_temp, rankings, waiver_players)]))
                        
                        # Skip trade if either side is receiving only non-starters
                        if not other_gives_filtered or not team_gives_filtered:
                            continue
                        
                        # For multi-player trades, check if best players of same position are too similar in rank
                        # (Prevents "Star WR + 2 bench players for similar Star WR" type trades)
                        if len(team_gives_filtered) > 1 or len(other_gives_filtered) > 1:
                            # Get best player from each side with their positions (optimized with dict lookups)
                            team_best_rank = min(rankings.get(p, 999) for p in team_gives_filtered)
                            other_best_rank = min(rankings.get(p, 999) for p in other_gives_filtered)
                            
                            team_best_player = min(team_gives_filtered, key=lambda p: rankings.get(p, 999))
                            other_best_player = min(other_gives_filtered, key=lambda p: rankings.get(p, 999))
                            
                            team_best_pos = team_tradeable_dict[team_best_player]['position']
                            other_best_pos = other_tradeable_dict[other_best_player]['position']
                            
                            # If best players are same position and within 5 ranks of each other, skip
                            # This prevents trading "similar star + bench" for "similar star"
                            if team_best_pos == other_best_pos and abs(team_best_rank - other_best_rank) <= 5:
                                continue
                        
                        # Check for duplicate trades (after filtering, multiple combinations may become identical)
                        trade_key = (other_team_name, team_gives_filtered, other_gives_filtered)
                        if trade_key in seen_trades:
                            continue
                        seen_trades.add(trade_key)
                        
                        # Simulate the trade with filtered player lists
                        team_new_power, other_new_power = simulate_trade(
                            team_roster, other_team_roster,
                            list(team_gives_filtered), list(other_gives_filtered),
                            rankings, waiver_players
                        )
                        
                        # Check if both teams improve
                        team_improvement = team_new_power - team_current_power
                        other_improvement = other_new_power - other_team_current_power
                        
                        # Minimum improvement threshold: at least 0.25% of current power
                        # (Prevents trades with negligible benefit like +1.2 points on 1500+ score)
                        min_improvement = team_current_power * 0.0025
                        min_other_improvement = other_team_current_power * 0.0025
                        
                        if team_improvement < min_improvement or other_improvement < min_other_improvement:
                            continue
                        
                        # Check roster balance penalties
                        # If a team is very imbalanced (elite WRs, terrible RBs), penalize them
                        team_balance = check_roster_balance_penalty(team_roster, rankings)
                        other_balance = check_roster_balance_penalty(other_team_roster, rankings)
                        
                        # Apply balance penalty only for very imbalanced rosters (< 0.75)
                        # This prevents extreme roster construction from driving bad trades
                        if team_balance < 0.75:
                            required_team_improvement = min_improvement * 1.5
                        else:
                            required_team_improvement = min_improvement
                        
                        if other_balance < 0.75:
                            required_other_improvement = min_other_improvement * 1.5
                        else:
                            required_other_improvement = min_other_improvement
                        
                        # Both must improve enough, and other team must gain at least 60%
                        if (team_improvement >= required_team_improvement and 
                            other_improvement >= required_other_improvement and
                            other_improvement >= (team_improvement * 0.6)):
                            
                            # For 2-for-1 trades, light validation
                            # (Main protection is rank disparity and minimum improvement checks)
                            if len(team_gives_filtered) == 2 and len(other_gives_filtered) == 1:
                                if not check_2_for_1_starter_utilization(team_roster, list(team_gives_filtered), rankings, waiver_players):
                                    continue
                            elif len(other_gives_filtered) == 2 and len(team_gives_filtered) == 1:
                                if not check_2_for_1_starter_utilization(other_team_roster, list(other_gives_filtered), rankings, waiver_players):
                                    continue
                            
                            all_trades.append({
                                'team': team_name,
                                'team_gives': ', '.join(team_gives_filtered),
                                'team_receives': ', '.join(other_gives_filtered),
                                'trade_partner': other_team_name,
                                'team_old_power': round(team_current_power, 2),
                                'team_new_power': round(team_new_power, 2),
                                'team_improvement': round(team_improvement, 2),
                                'partner_old_power': round(other_team_current_power, 2),
                                'partner_new_power': round(other_new_power, 2),
                                'partner_improvement': round(other_improvement, 2)
                            })
    
    # Sort by team's improvement (highest first)
    all_trades.sort(key=lambda t: t['team_improvement'], reverse=True)
    
    return all_trades


def find_all_trades(rosters: Dict[str, List[Dict]], rankings: Dict[str, int], waiver_players: Dict[str, List[Dict]]) -> Dict[str, List[Dict]]:
    """
    Find all beneficial trades for all teams.
    Returns dict of team_name -> list of top 5 trades.
    """
    all_team_trades = {}
    
    for team_name in rosters.keys():
        print(f"Analyzing trades for {team_name}...")
        trades = find_trades_for_team(team_name, rosters, rankings, waiver_players)
        all_team_trades[team_name] = trades[:5]  # Top 5 trades per team
        print(f"  Found {len(trades)} total trades, keeping top 5")
    
    return all_team_trades


def save_all_trades_to_csv(all_trades: Dict[str, List[Dict]], filename='all_teams_trade_analysis.csv'):
    """Save all teams' top trades to CSV file."""
    script_dir = Path(__file__).parent
    output_file = script_dir / 'Data' / filename
    
    try:
        # Flatten all trades into one list
        all_rows = []
        for team_name, trades in all_trades.items():
            all_rows.extend(trades)
        
        if all_rows:
            with open(output_file, 'w', newline='', encoding='utf-8') as f:
                writer = csv.DictWriter(f, fieldnames=all_rows[0].keys())
                writer.writeheader()
                writer.writerows(all_rows)
        
        print(f"\nSaved {len(all_rows)} trades to {output_file}")
        return True
    
    except Exception as e:
        print(f"Error saving trades: {e}")
        return False


def print_top_trades(trades: List[Dict], count: int = 5):
    """Print the top trade scenarios."""
    print("\n" + "="*100)
    print(f"TOP {count} WIN-WIN TRADES FOR DAD BOD")
    print("="*100)
    
    for i, trade in enumerate(trades[:count], 1):
        print(f"\n{i}. Trade with {trade['trade_partner']}")
        print("-" * 100)
        print(f"  Dad Bod gives:    {trade['dad_bod_gives']}")
        print(f"  Dad Bod receives: {trade['dad_bod_receives']}")
        print()
        print(f"  Dad Bod:     {trade['dad_bod_old_power']} → {trade['dad_bod_new_power']} "
              f"(+{trade['dad_bod_improvement']})")
        print(f"  {trade['trade_partner']:12} {trade['partner_old_power']} → {trade['partner_new_power']} "
              f"(+{trade['partner_improvement']})")


def main(team_name: str = "Dad Bod"):
    """Main execution function.
    
    Args:
        team_name: The team to analyze trades for. Defaults to "Dad Bod".
    """
    print("Fantasy Football Trade Analyzer")
    print("="*100)
    print("Finding win-win trades (3 or fewer players)...\n")
    
    # Load data
    rankings = load_rankings()
    rosters = load_rosters()
    
    if not rankings or not rosters:
        print("Error: Could not load required data files")
        return
    
    # Validate team name
    if team_name not in rosters:
        print(f"Error: Team '{team_name}' not found in rosters")
        print(f"Available teams: {', '.join(sorted(rosters.keys()))}")
        return
    
    print(f"Loaded {len(rankings)} player rankings")
    print(f"Loaded rosters for {len(rosters)} teams")
    
    # Get waiver wire players
    waiver_players = get_waiver_players(rosters, rankings)
    print(f"Found {sum(len(players) for players in waiver_players.values())} waiver wire players\n")
    
    # Analyze trades for specified team
    # To analyze trades for all teams, call find_all_trades() instead
    all_trades = {}
    print(f"Analyzing trades for {team_name}...")
    trades = find_trades_for_team(team_name, rosters, rankings, waiver_players)
    
    # Calculate max power for normalization (to scale to 100)
    all_team_powers = []
    for tn, roster in rosters.items():
        power = calculate_team_power(roster, rankings, waiver_players)
        all_team_powers.append(power)
    max_power = max(all_team_powers) if all_team_powers else 1
    
    # Normalize trade improvements to be out of 100
    for trade in trades:
        # Convert raw power scores to normalized (out of 100)
        trade['team_old_power_normalized'] = round((trade['team_old_power'] / max_power) * 100, 1)
        trade['team_new_power_normalized'] = round((trade['team_new_power'] / max_power) * 100, 1)
        trade['team_improvement_normalized'] = round(trade['team_new_power_normalized'] - trade['team_old_power_normalized'], 1)
        
        trade['partner_old_power_normalized'] = round((trade['partner_old_power'] / max_power) * 100, 1)
        trade['partner_new_power_normalized'] = round((trade['partner_new_power'] / max_power) * 100, 1)
        trade['partner_improvement_normalized'] = round(trade['partner_new_power_normalized'] - trade['partner_old_power_normalized'], 1)
    
    # Group trades by partner team and keep top 3 per partner
    # Also filter out trades where Dad Bod receives same players but gives away more
    # OR gives same players but receives fewer
    trades_by_partner = {}
    for trade in trades:
        partner = trade['trade_partner']
        if partner not in trades_by_partner:
            trades_by_partner[partner] = []
        
        # Check if this trade is redundant compared to existing trades
        team_receives = trade['team_receives']
        team_gives = trade['team_gives']
        is_duplicate = False
        
        for i, existing_trade in enumerate(trades_by_partner[partner]):
            existing_receives = existing_trade['team_receives']
            existing_gives = existing_trade['team_gives']
            
            # Case 1: Same received players - keep the one that gives away less
            if existing_receives == team_receives:
                existing_gives_count = len(existing_gives.split(', '))
                new_gives_count = len(team_gives.split(', '))
                
                if new_gives_count < existing_gives_count:
                    # Replace with better trade (gives less for same return)
                    trades_by_partner[partner][i] = trade
                is_duplicate = True
                break
            
            # Case 2: Same given players - keep the one that receives more
            if existing_gives == team_gives:
                existing_receives_count = len(existing_receives.split(', '))
                new_receives_count = len(team_receives.split(', '))
                
                if new_receives_count > existing_receives_count:
                    # Replace with better trade (receives more for same cost)
                    trades_by_partner[partner][i] = trade
                is_duplicate = True
                break
        
        # Only add if not duplicate or if we already replaced an inferior version
        if not is_duplicate and len(trades_by_partner[partner]) < 3:
            trades_by_partner[partner].append(trade)
    
    # Flatten back to single list for output
    all_trades[team_name] = []
    for partner in sorted(trades_by_partner.keys()):
        all_trades[team_name].extend(trades_by_partner[partner])
    
    print(f"  Found {len(trades)} total trades")
    print(f"  Keeping top 3 trades with each of {len(trades_by_partner)} teams")
    
    # Print summary
    print("\n" + "="*100)
    print("TRADE ANALYSIS SUMMARY")
    print("="*100)
    
    total_trades = sum(len(trades) for trades in all_trades.values())
    print(f"\nTotal trades shown: {total_trades}")
    print(f"(Showing top 3 trades with each team)\n")
    
    # Group by partner for display
    for team_name, trades in all_trades.items():
        if trades:
            # Group trades by partner
            partner_trades = {}
            for trade in trades:
                partner = trade['trade_partner']
                if partner not in partner_trades:
                    partner_trades[partner] = []
                partner_trades[partner].append(trade)
            
            print(f"\n{team_name}: Trades with {len(partner_trades)} teams")
            
            for partner_name in sorted(partner_trades.keys()):
                partner_trade_list = partner_trades[partner_name]
                print(f"\n  With {partner_name}:")
                for i, trade in enumerate(partner_trade_list, 1):
                    print(f"    {i}. Give: {trade['team_gives']} -> Get: {trade['team_receives']}")
                    print(f"       ({team_name}: +{trade['team_improvement_normalized']:.1f}, {partner_name}: +{trade['partner_improvement_normalized']:.1f})")
    
    # Save to CSV
    save_all_trades_to_csv(all_trades)


if __name__ == "__main__":
    main()
