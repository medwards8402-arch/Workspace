"""
Scrape NFL Fantasy League roster information from FantasyPros.
Captures team names and their rostered players from a synced league.
Requires browser cookies from an authenticated FantasyPros session.
"""

import requests
from bs4 import BeautifulSoup
import csv
from pathlib import Path
import re
import json
from concurrent.futures import ThreadPoolExecutor, as_completed
import time


def parse_roster_json(data):
    """Parse roster data from API JSON response."""
    rosters = []
    
    try:
        # Try different possible JSON structures
        if isinstance(data, dict):
            # Check for teams list
            teams_data = data.get('teams', data.get('data', {}).get('teams', []))
            
            for team in teams_data:
                team_name = team.get('name', team.get('team_name', 'Unknown Team'))
                players = team.get('roster', team.get('players', []))
                
                for player in players:
                    rosters.append({
                        'team': team_name,
                        'player': player.get('name', player.get('player_name', 'Unknown')),
                        'position': player.get('position', player.get('pos', 'N/A'))
                    })
        
        elif isinstance(data, list):
            # Data is directly a list of teams
            for team in data:
                team_name = team.get('name', team.get('team_name', 'Unknown Team'))
                players = team.get('roster', team.get('players', []))
                
                for player in players:
                    rosters.append({
                        'team': team_name,
                        'player': player.get('name', player.get('player_name', 'Unknown')),
                        'position': player.get('position', player.get('pos', 'N/A'))
                    })
    
    except Exception as e:
        print(f"Error parsing roster JSON: {e}")
    
    return rosters


def parse_team_roster_html(html_content, team_name):
    """Parse roster information from FantasyPros My Team HTML page."""
    rosters = []
    
    try:
        soup = BeautifulSoup(html_content, 'html.parser')
        
        # Find all player rows in the overview table
        player_rows = soup.find_all('tr', class_='player-row')
        
        for row in player_rows:
            try:
                # Extract position
                pos_cell = row.find('td', class_=re.compile(r'position-border'))
                position = pos_cell.get_text(strip=True) if pos_cell else 'N/A'
                
                # Extract player name - look for the full name span
                player_name_elem = row.find('span', class_='player-info__name--full-name')
                if not player_name_elem:
                    player_name_elem = row.find('span', class_='player-info__name--short-name')
                
                player_name = player_name_elem.get_text(strip=True) if player_name_elem else 'Unknown'
                
                # Skip if we couldn't extract basic info
                if player_name and player_name != 'Unknown':
                    rosters.append({
                        'team': team_name,
                        'player': player_name,
                        'position': position
                    })
            except Exception as e:
                # Skip rows that don't parse correctly
                continue
    
    except Exception as e:
        print(f"Error parsing team roster HTML: {e}")
    
    return rosters


def scrape_single_team_roster(cookies_dict, my_team_url, team_id, team_name):
    """Scrape a single team's roster with retry logic (used for parallel processing)."""
    max_retries = 2
    retry_delay = 3  # seconds
    timeout = 60  # seconds - give server plenty of time to respond
    
    for attempt in range(max_retries):
        try:
            # Create a new session for this thread
            thread_session = requests.Session()
            for key, value in cookies_dict.items():
                thread_session.cookies.set(key, value, domain='.fantasypros.com', path='/')
            
            # Add a small delay to avoid overwhelming the server
            if attempt > 0:
                time.sleep(1)
            
            team_url = f"{my_team_url}?team={team_id}"
            team_response = thread_session.get(team_url, timeout=timeout)
            
            if team_response.status_code == 200:
                team_roster = parse_team_roster_html(team_response.text, team_name)
                if attempt > 0:
                    print(f"  ✓ {team_name}: {len(team_roster)} players (retry {attempt})")
                else:
                    print(f"  ✓ {team_name}: {len(team_roster)} players")
                return team_roster
            elif team_response.status_code == 429:  # Rate limited
                if attempt < max_retries - 1:
                    wait_time = retry_delay * (2 ** attempt)  # Exponential backoff
                    print(f"  ⟳ {team_name}: Rate limited, retrying in {wait_time}s...")
                    time.sleep(wait_time)
                    continue
                else:
                    print(f"  ✗ {team_name}: Rate limited after {max_retries} attempts")
                    return []
            else:
                print(f"  ✗ {team_name}: HTTP {team_response.status_code}")
                return []
                
        except requests.exceptions.Timeout:
            if attempt < max_retries - 1:
                wait_time = retry_delay * (2 ** attempt)
                print(f"  ⟳ {team_name}: Timeout, retrying in {wait_time}s...")
                time.sleep(wait_time)
                continue
            else:
                print(f"  ✗ {team_name}: Timeout after {max_retries} attempts")
                return []
                
        except Exception as e:
            if attempt < max_retries - 1:
                wait_time = retry_delay * (2 ** attempt)
                error_msg = str(e)[:40]
                print(f"  ⟳ {team_name}: {error_msg}... retrying in {wait_time}s")
                time.sleep(wait_time)
                continue
            else:
                print(f"  ✗ {team_name}: {str(e)[:50]}")
                return []
    
    return []


def scrape_league_rosters_fantasypros(league_key, session):
    """Scrape roster information from FantasyPros My Playbook."""
    
    # Try the "My Team" page which should have roster info
    my_team_url = "https://www.fantasypros.com/nfl/myplaybook/my-team.php"
    print(f"Checking my-team page: {my_team_url}")
    try:
        response = session.get(my_team_url)
        print(f"My-team page status: {response.status_code}")
        
        if response.status_code == 200:
            soup = BeautifulSoup(response.content, 'html.parser')
            
            # Extract team information from FP.mpbNavSettings
            settings_match = re.search(r'FP\.mpbNavSettings\s*=\s*(\{.*?\});', response.text, re.DOTALL)
            if settings_match:
                try:
                    settings_data = json.loads(settings_match.group(1))
                    league_teams = settings_data.get('leagueTeams', {})
                    
                    print(f"Found {len(league_teams)} teams in league")
                    print(f"Fetching all team rosters in parallel ({len(league_teams)} concurrent requests)...\n")
                    
                    start_time = time.time()
                    
                    # Extract cookies to dict for thread-safe sessions
                    cookies_dict = {cookie.name: cookie.value for cookie in session.cookies}
                    
                    # Now scrape each team's roster IN PARALLEL (max workers = number of teams)
                    all_rosters = []
                    failed_teams = []
                    with ThreadPoolExecutor(max_workers=len(league_teams)) as executor:
                        # Submit all team scraping tasks
                        future_to_team = {
                            executor.submit(scrape_single_team_roster, cookies_dict, my_team_url, team_id, team_info.get('text', 'Unknown Team')): (team_id, team_info.get('text', 'Unknown Team'))
                            for team_id, team_info in league_teams.items()
                        }
                        
                        # Collect results as they complete
                        for future in as_completed(future_to_team):
                            team_id, team_name = future_to_team[future]
                            team_roster = future.result()
                            if team_roster:
                                all_rosters.extend(team_roster)
                            else:
                                failed_teams.append(team_name)
                    
                    elapsed = time.time() - start_time
                    successful_teams = len(league_teams) - len(failed_teams)
                    print(f"\n✓ Fetched {len(all_rosters)} total players from {successful_teams}/{len(league_teams)} teams in {elapsed:.1f}s")
                    
                    if failed_teams:
                        print(f"\n⚠ Failed to fetch rosters for {len(failed_teams)} team(s):")
                        for team in failed_teams:
                            print(f"  - {team}")
                        print("\nTip: These teams may have loaded successfully if you run the script again.")
                    
                    if all_rosters:
                        return all_rosters
                        
                except Exception as e:
                    print(f"Error parsing team settings: {e}")
            
    except Exception as e:
        print(f"Error checking my-team page: {e}")
    
    # If the main my-team page didn't work, return empty
    return []


def save_to_csv(rosters, filename='league_rosters.csv'):
    """Save roster data to CSV file in the script's directory."""
    script_dir = Path(__file__).parent
    output_file = script_dir / 'Data' / filename
    
    try:
        with open(output_file, 'w', newline='', encoding='utf-8') as f:
            writer = csv.DictWriter(f, fieldnames=['team', 'player', 'position'])
            writer.writeheader()
            writer.writerows(rosters)
        
        print(f"Successfully saved {len(rosters)} roster entries to {output_file}")
        return True
    
    except Exception as e:
        print(f"Error saving to file: {e}")
        return False


def main():
    """Main execution function."""
    print("FantasyPros League Roster Scraper")
    print("=" * 50)
    
    # Create session
    session = requests.Session()
    
    # Hardcode the fptoken authentication cookie
    fptoken = "gAAAAABpC86x3rXi9FshfX8jagSfXJn6ncfVbVD9sCbBLAssFVKdKpP8w_aLLdnrsmBhVEHPKU11ThRtegKs2S2IihL1wkAUnhr9lKKQUI9M9yNqqIejdvc%3D%3A1762410296"
    session.cookies.set('fptoken', fptoken, domain='.fantasypros.com', path='/')
    print("Using hardcoded fptoken for authentication\n")
    
    # Get synced leagues
    print("Fetching your synced leagues...")
    
    # Hardcoded league key
    league_key = "nfl~66c3e71a-0995-4011-80c7-01fa9798565e"
    print(f"Using hardcoded league key: {league_key}\n")
    
    if league_key:
        print(f"Scraping league with key: {league_key}...")
        rosters = scrape_league_rosters_fantasypros(league_key, session)
        
        if rosters:
            unique_teams = len(set(r['team'] for r in rosters))
            print(f"\nSuccessfully scraped rosters for {unique_teams} teams")
            print(f"Total roster entries: {len(rosters)}")
            save_to_csv(rosters)
        else:
            print("\nNo roster data found.")
            print("Tips:")
            print("- Make sure you're logged into FantasyPros in your browser")
            print("- Verify the league is synced to your account")
            print("- Check that you have access to view rosters")
    else:
        print("No league key provided")


if __name__ == "__main__":
    main()
