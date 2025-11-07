"""
Scrape NFL player rankings from FantasyPros.
Captures ranking, name, and position for the top 399 players.
"""

import requests
from bs4 import BeautifulSoup
import csv
from pathlib import Path
import re
import json


def scrape_fantasy_rankings():
    """Scrape player rankings from FantasyPros."""
    url = "https://www.fantasypros.com/nfl/rankings/ros-half-point-ppr-overall.php"
    
    headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
    }
    
    try:
        response = requests.get(url, headers=headers)
        response.raise_for_status()
        
        # Find the ecrData JSON in the page source
        players = []
        
        # Use regex to find the ecrData variable
        pattern = r'var ecrData = (\{.*?\});'
        match = re.search(pattern, response.text, re.DOTALL)
        
        if match:
            json_str = match.group(1)
            
            try:
                data = json.loads(json_str)
                
                # Extract player information from the JSON
                if 'players' in data:
                    for player in data['players'][:399]:  # Get first 399 players
                        rank = player.get('rank_ecr', '')
                        name = player.get('player_name', '')
                        position = player.get('player_position_id', '')
                        
                        if rank and name and position:
                            players.append({
                                'rank': str(rank),
                                'name': name,
                                'position': position
                            })
                
                print(f"Successfully scraped {len(players)} players from JSON data")
                    
            except json.JSONDecodeError as e:
                print(f"Error parsing JSON: {e}")
                print(f"JSON string length: {len(json_str)}")
                print(f"First 200 chars: {json_str[:200]}")
                print(f"Last 200 chars: {json_str[-200:]}")
        else:
            print("Could not find ecrData in page source")
        
        return players
    
    except requests.RequestException as e:
        print(f"Error fetching data: {e}")
        return []


def save_to_csv(players, filename='nfl_rankings.csv'):
    """Save player rankings to CSV file in the script's directory."""
    # Get the directory where this script is located
    script_dir = Path(__file__).parent
    output_file = script_dir / 'Data' / filename
    
    try:
        with open(output_file, 'w', newline='', encoding='utf-8') as f:
            writer = csv.DictWriter(f, fieldnames=['rank', 'name', 'position'])
            writer.writeheader()
            writer.writerows(players)
        
        print(f"Successfully saved {len(players)} players to {output_file}")
        return True
    
    except Exception as e:
        print(f"Error saving to file: {e}")
        return False


def main():
    """Main execution function."""
    print("Scraping NFL player rankings from FantasyPros...")
    players = scrape_fantasy_rankings()
    
    if players:
        print(f"Successfully scraped {len(players)} players")
        save_to_csv(players)
    else:
        print("No players found. Please check the website structure.")


if __name__ == "__main__":
    main()
