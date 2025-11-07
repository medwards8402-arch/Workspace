"""
Calculate the power ranking for each fantasy football team.
Uses roster data and player rankings to determine team strength based on starter positions.

Starter positions and weights:
- QB (1.0x weight)
- RB, RB (1.0x weight)
- WR, WR (1.0x weight)
- TE (0.3x weight)
- W/R, R/W/T (1.0x weight for flex positions)
- DEF (0.3x weight)
- K (0.4x weight)
"""

import csv
from pathlib import Path
from typing import Dict, List

from common.fantasy_utils import (
    load_rankings,
    load_rosters,
    select_starters,
    get_waiver_players
)


def calculate_all_team_power(rosters: Dict[str, List[Dict]], rankings: Dict[str, int], waiver_players: Dict[str, List[Dict]] = None) -> List[Dict]:
    """Calculate power rankings for all teams."""
    team_powers = []
    
    for team_name, roster in rosters.items():
        starters, power_score = select_starters(roster, rankings, waiver_players)
        
        team_powers.append({
            'team': team_name,
            'raw_power_score': power_score,
            'starters': starters
        })
    
    # Sort by power score (highest first)
    team_powers.sort(key=lambda t: t['raw_power_score'], reverse=True)
    
    # Normalize scores so the best team has 100
    if team_powers:
        max_score = team_powers[0]['raw_power_score']
        for team_data in team_powers:
            normalized_score = (team_data['raw_power_score'] / max_score) * 100
            team_data['power_score'] = round(normalized_score, 0)
    
    return team_powers


def save_team_power(team_powers: List[Dict], filename='team_power_rankings.csv'):
    """Save team power rankings to CSV."""
    script_dir = Path(__file__).parent
    output_file = script_dir / 'Data' / filename
    
    try:
        with open(output_file, 'w', newline='', encoding='utf-8') as f:
            writer = csv.DictWriter(f, fieldnames=['rank', 'team', 'power_score'])
            writer.writeheader()
            
            for i, team_data in enumerate(team_powers, 1):
                writer.writerow({
                    'rank': i,
                    'team': team_data['team'],
                    'power_score': team_data['power_score']
                })
        
        print(f"\nSaved team power rankings to {output_file}")
        return True
    
    except Exception as e:
        print(f"Error saving team power rankings: {e}")
        return False


def print_team_power(team_powers: List[Dict]):
    """Print team power rankings with starters."""
    print("\n" + "="*80)
    print("TEAM POWER RANKINGS")
    print("="*80)
    
    for i, team_data in enumerate(team_powers, 1):
        print(f"\n{i}. {team_data['team']} - Power Score: {team_data['power_score']}")
        print("-" * 80)
        
        starters = team_data['starters']
        for starter in starters:
            rank_str = f"#{starter['rank']}" if starter['rank'] > 0 else "Unranked"
            print(f"  {starter['position']:4} {starter['name']:30} {rank_str:>12}  (Score: {starter['score']:.1f})")


def main():
    """Main execution function."""
    print("NFL Fantasy Team Power Calculator")
    print("="*80)
    
    # Load data
    rankings = load_rankings()
    rosters = load_rosters()
    
    if not rankings or not rosters:
        print("Error: Could not load required data files")
        return
    
    # Get waiver wire players
    waiver_players = get_waiver_players(rosters, rankings)
    print(f"Found {sum(len(players) for players in waiver_players.values())} waiver wire players")
    
    # Calculate team power
    team_powers = calculate_all_team_power(rosters, rankings, waiver_players)
    
    # Display results
    print_team_power(team_powers)
    
    # Save to CSV
    save_team_power(team_powers)


if __name__ == "__main__":
    main()
