"""
Core fantasy football utilities for power calculations and data loading.
Shared across multiple NFL analysis scripts.
"""

import csv
from pathlib import Path
from typing import Dict, List, Tuple


# Position weights based on importance
POSITION_WEIGHTS = {
    'QB': 1.50,  # Elite QBs are game-changers - uses absolute ranks
    'RB': 1.00,  # RB uses absolute ranks - balanced weight
    'WR': 1.10,  # WR uses absolute ranks - valuable for flex spots
    'TE': 0.84,  # Elite TEs are valuable - uses absolute ranks
    'DST': 0.15, # DST scores relative to other DSTs - properly scaled with offsets
    'K': 0.32    # K scores relative to other Ks - properly scaled with offsets
}

# Position-specific exponential decay rates for rank-based scoring
# Steeper decay (lower number) = more separation between elite and average
POSITION_DECAY_RATES = {
    'QB': 0.965,  # Steeper - only ~12 elite QBs, need strong differentiation
    'RB': 0.970,  # Standard - good depth and value spread
    'WR': 0.970,  # Standard - deepest position with consistent value
    'TE': 0.963,  # Steepest - extreme scarcity, elite TEs are game-changers
    'DST': 0.970, # Standard - offsets normalize the range already
    'K': 0.970    # Standard - offsets normalize the range already
}

# Position-specific rank offsets - calculated dynamically on first use
# This ensures DST/K score relative to other DST/K, not the entire player pool
_POSITION_RANK_OFFSETS = None


def _calculate_position_offsets(filename='nfl_rankings.csv') -> Dict[str, int]:
    """
    Calculate position-specific rank offsets based on the first occurrence of each position.
    This allows positions to score relative to other players at their position.
    QB, TE, DST, and K use offsets; RB and WR use absolute ranks for overall comparison.
    """
    script_dir = Path(__file__).parent.parent
    rankings_file = script_dir / 'Data' / filename
    
    offsets = {}
    first_rank_by_position = {}
    
    try:
        with open(rankings_file, 'r', encoding='utf-8') as f:
            reader = csv.DictReader(f)
            for row in reader:
                position = row['position']
                rank = int(row['rank'])
                
                # Track the first (lowest) rank for each position
                if position not in first_rank_by_position:
                    first_rank_by_position[position] = rank
        
        # Apply offsets to DST and K - these positions score relative to their position
        # QB, RB, WR, and TE use absolute ranks to maintain cross-position comparison
        for position, first_rank in first_rank_by_position.items():
            if position in ['DST', 'K']:
                offsets[position] = first_rank - 1
            else:
                offsets[position] = 0
    
    except Exception as e:
        print(f"Error calculating position offsets: {e}")
        # Return default offsets if file can't be read
        return {'QB': 0, 'RB': 0, 'WR': 0, 'TE': 0, 'DST': 0, 'K': 0}
    
    return offsets


def get_position_rank_offsets() -> Dict[str, int]:
    """Get position rank offsets, calculating them once on first call."""
    global _POSITION_RANK_OFFSETS
    if _POSITION_RANK_OFFSETS is None:
        _POSITION_RANK_OFFSETS = _calculate_position_offsets()
    return _POSITION_RANK_OFFSETS


def load_rankings(filename='nfl_rankings.csv') -> Dict[str, int]:
    """Load player rankings from CSV. Returns dict of player_name -> rank."""
    # Look for file in parent directory's Data folder (NFL/Data/)
    script_dir = Path(__file__).parent.parent
    rankings_file = script_dir / 'Data' / filename
    
    rankings = {}
    try:
        with open(rankings_file, 'r', encoding='utf-8') as f:
            reader = csv.DictReader(f)
            for row in reader:
                name = row['name']
                rank = int(row['rank'])
                rankings[name] = rank
        
        return rankings
    
    except FileNotFoundError:
        print(f"Error: {rankings_file} not found")
        return {}
    except Exception as e:
        print(f"Error loading rankings: {e}")
        return {}


def load_rosters(filename='league_rosters.csv') -> Dict[str, List[Dict]]:
    """Load team rosters from CSV. Returns dict of team_name -> list of players."""
    # Look for file in parent directory's Data folder (NFL/Data/)
    script_dir = Path(__file__).parent.parent
    rosters_file = script_dir / 'Data' / filename
    
    rosters = {}
    try:
        with open(rosters_file, 'r', encoding='utf-8') as f:
            reader = csv.DictReader(f)
            for row in reader:
                team = row['team']
                player = row['player']
                position = row['position']
                
                if team not in rosters:
                    rosters[team] = []
                
                rosters[team].append({
                    'name': player,
                    'position': position
                })
        
        return rosters
    
    except FileNotFoundError:
        print(f"Error: {rosters_file} not found")
        return {}
    except Exception as e:
        print(f"Error loading rosters: {e}")
        return {}


def get_player_score(rank: int, position: str) -> float:
    """
    Calculate player score based on rank and position weight.
    Lower rank = higher score (rank 1 is best).
    Uses exponential decay to emphasize elite players over average ones.
    
    Score formula:
    - Base score uses exponential decay: 500 * (DECAY_RATE ^ adjusted_rank)
    - For DST/K, we normalize their ranks (subtract position offset) so they score
      relative to other DST/K, not the entire player pool
    - This heavily rewards elite players (rank 1-20) vs average (rank 100+)
    - Then multiply by position weight
    
    The exponential decay already captures player quality differences.
    No additional slot multipliers needed - rank determines value.
    """
    if rank == 0:
        return 0.0
    
    # Normalize rank for DST/K positions that start much later in overall rankings
    # This prevents the decay function from crushing their scores
    offsets = get_position_rank_offsets()
    offset = offsets.get(position, 0)
    adjusted_rank = rank - offset
    
    # Position-specific exponential decay: elite players worth significantly more than average
    # QB/TE use steeper decay due to scarcity; RB/WR use standard decay
    decay_rate = POSITION_DECAY_RATES.get(position, 0.970)
    base_score = 500 * (decay_rate ** adjusted_rank)
    
    # Apply position weight
    weight = POSITION_WEIGHTS.get(position, 1.0)
    score = base_score * weight
    
    return score


def select_starters(roster: List[Dict], rankings: Dict[str, int], waiver_players: Dict[str, List[Dict]] = None) -> Tuple[List[Dict], float]:
    """
    Select the best starters from a roster based on league positions.
    If waiver_players provided, fills empty positions with best available free agents.
    Returns list of selected starters and total team power score.
    
    League positions: 1 QB, 2 RB, 2 WR, 1 TE, 1 W/R flex, 1 R/W/T flex, 1 DST, 1 K
    
    Now applies starter slot multipliers to differentiate elite starters from depth.
    """
    # Add rankings to each player (base score without slot multiplier)
    for player in roster:
        player['rank'] = rankings.get(player['name'], 0)
        player['base_score'] = get_player_score(player['rank'], player['position'])
    
    # Sort players by base score (highest first)
    sorted_roster = sorted(roster, key=lambda p: p['base_score'], reverse=True)
    
    # Group players by position
    by_position = {}
    for player in sorted_roster:
        pos = player['position']
        if pos not in by_position:
            by_position[pos] = []
        by_position[pos].append(player)
    
    starters = []
    total_score = 0.0
    
    # Select QB
    if 'QB' in by_position and by_position['QB']:
        qb = by_position['QB'][0]
        qb['slot'] = 'QB1'
        qb['score'] = get_player_score(qb['rank'], qb['position'])
        starters.append(qb)
        total_score += qb['score']
        by_position['QB'].pop(0)
    
    # Select 2 RBs
    if 'RB' in by_position:
        for i, slot in enumerate(['RB1', 'RB2']):
            if i < len(by_position['RB']):
                rb = by_position['RB'][0]
                rb['slot'] = slot
                rb['score'] = get_player_score(rb['rank'], rb['position'])
                starters.append(rb)
                total_score += rb['score']
                by_position['RB'].pop(0)
    
    # Select 2 WRs
    if 'WR' in by_position:
        for i, slot in enumerate(['WR1', 'WR2']):
            if i < len(by_position['WR']):
                wr = by_position['WR'][0]
                wr['slot'] = slot
                wr['score'] = get_player_score(wr['rank'], wr['position'])
                starters.append(wr)
                total_score += wr['score']
                by_position['WR'].pop(0)
    
    # Select 1 TE
    if 'TE' in by_position and by_position['TE']:
        te = by_position['TE'][0]
        te['slot'] = 'TE1'
        te['score'] = get_player_score(te['rank'], te['position'])
        starters.append(te)
        total_score += te['score']
        by_position['TE'].pop(0)
    
    # Select W/R flex (best remaining WR or RB)
    flex_wr_candidates = []
    if 'WR' in by_position:
        flex_wr_candidates.extend(by_position['WR'])
    if 'RB' in by_position:
        flex_wr_candidates.extend(by_position['RB'])
    
    if flex_wr_candidates:
        flex_wr_candidates.sort(key=lambda p: p['base_score'], reverse=True)
        flex_wr = flex_wr_candidates[0]
        flex_wr['slot'] = 'FLEX1'
        flex_wr['score'] = get_player_score(flex_wr['rank'], flex_wr['position'])
        starters.append(flex_wr)
        total_score += flex_wr['score']
        
        # Remove from original position list
        if flex_wr in by_position.get('WR', []):
            by_position['WR'].remove(flex_wr)
        elif flex_wr in by_position.get('RB', []):
            by_position['RB'].remove(flex_wr)
    
    # Select R/W/T flex (best remaining RB, WR, or TE)
    flex_flex_candidates = []
    if 'RB' in by_position:
        flex_flex_candidates.extend(by_position['RB'])
    if 'WR' in by_position:
        flex_flex_candidates.extend(by_position['WR'])
    if 'TE' in by_position:
        flex_flex_candidates.extend(by_position['TE'])
    
    if flex_flex_candidates:
        flex_flex_candidates.sort(key=lambda p: p['base_score'], reverse=True)
        flex_flex = flex_flex_candidates[0]
        flex_flex['slot'] = 'FLEX2'
        flex_flex['score'] = get_player_score(flex_flex['rank'], flex_flex['position'])
        starters.append(flex_flex)
        total_score += flex_flex['score']
    
    # Select DST
    if 'DST' in by_position and by_position['DST']:
        dst = by_position['DST'][0]
        dst['slot'] = 'DST'
        dst['score'] = get_player_score(dst['rank'], dst['position'])
        starters.append(dst)
        total_score += dst['score']
    elif waiver_players and 'DST' in waiver_players and waiver_players['DST']:
        # Fill with best waiver DST
        dst = waiver_players['DST'][0].copy()
        dst['slot'] = 'DST'
        dst['score'] = get_player_score(dst['rank'], dst['position'])
        starters.append(dst)
        total_score += dst['score']
    
    # Select K
    if 'K' in by_position and by_position['K']:
        k = by_position['K'][0]
        k['slot'] = 'K'
        k['score'] = get_player_score(k['rank'], k['position'])
        starters.append(k)
        total_score += k['score']
    elif waiver_players and 'K' in waiver_players and waiver_players['K']:
        # Fill with best waiver K
        k = waiver_players['K'][0].copy()
        k['slot'] = 'K'
        k['score'] = get_player_score(k['rank'], k['position'])
        starters.append(k)
        total_score += k['score']
    
    return starters, total_score


def calculate_team_power(roster: List[Dict], rankings: Dict[str, int], waiver_players: Dict[str, List[Dict]] = None) -> float:
    """
    Calculate power score for a single team.
    Returns the team's total power score.
    """
    starters, power_score = select_starters(roster, rankings, waiver_players)
    return power_score


def get_waiver_players(rosters: Dict[str, List[Dict]], rankings: Dict[str, int]) -> Dict[str, List[Dict]]:
    """
    Get all players not on any roster (waiver wire / free agents).
    Returns dict of position -> sorted list of available players.
    """
    # Get all rostered player names
    rostered_names = set()
    for roster in rosters.values():
        for player in roster:
            rostered_names.add(player['name'])
    
    # Look for rankings file in parent directory's Data folder (NFL/Data/)
    script_dir = Path(__file__).parent.parent
    rankings_file = script_dir / 'Data' / 'nfl_rankings.csv'
    
    waiver_players = {}
    try:
        with open(rankings_file, 'r', encoding='utf-8') as f:
            reader = csv.DictReader(f)
            for row in reader:
                name = row['name']
                if name not in rostered_names:
                    position = row['position']
                    rank = int(row['rank'])
                    
                    if position not in waiver_players:
                        waiver_players[position] = []
                    
                    waiver_players[position].append({
                        'name': name,
                        'position': position,
                        'rank': rank,
                        'score': get_player_score(rank, position)
                    })
        
        # Sort each position by score (highest first)
        for position in waiver_players:
            waiver_players[position].sort(key=lambda p: p['score'], reverse=True)
    
    except Exception as e:
        print(f"Error loading waiver players: {e}")
        return {}
    
    return waiver_players
