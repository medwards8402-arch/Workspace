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
import browser_cookie3
from http.cookiejar import MozillaCookieJar


def load_cookies_from_file():
    """Load cookies from a file (JSON, Netscape, or tab-separated format)."""
    script_dir = Path(__file__).parent
    
    # Try the custom tab-separated format first (from Edge export)
    for cookie_filename in ['cookies.txt', 'cookies']:
        cookie_file = script_dir / cookie_filename
        if cookie_file.exists():
            print(f"Found cookie file: {cookie_file}")
            try:
                cookies = {}
                lines_processed = 0
                fp_lines = 0
                
                # Try different encodings
                for encoding in ['utf-8', 'utf-16', 'utf-16-le', 'latin-1']:
                    try:
                        with open(cookie_file, 'r', encoding=encoding) as f:
                            content = f.read()
                            if content:
                                print(f"Successfully read file with {encoding} encoding")
                                for line in content.split('\n'):
                                    line = line.strip()
                                    if not line or line.startswith('#'):
                                        continue
                                    
                                    lines_processed += 1
                                    # Parse tab-separated format: name\tvalue\tdomain\tpath\texpires\tsize\t...
                                    parts = line.split('\t')
                                    if len(parts) >= 3:
                                        name = parts[0]
                                        value = parts[1]
                                        domain = parts[2]
                                        
                                        # Only include cookies for fantasypros.com
                                        if 'fantasypros.com' in domain:
                                            fp_lines += 1
                                            cookies[name] = value
                                break
                    except (UnicodeDecodeError, UnicodeError):
                        continue
                
                print(f"Processed {lines_processed} cookie lines, found {fp_lines} FantasyPros cookies")
                if cookies:
                    print(f"Loaded {len(cookies)} FantasyPros cookies from file")
                    
                    # Check for critical authentication cookies
                    critical_cookies = ['fptoken']
                    missing = [c for c in critical_cookies if c not in cookies]
                    if missing:
                        print(f"\nWARNING: Missing critical authentication cookie: fptoken")
                        print("This is required for FantasyPros authentication!")
                        print("\nTo get fptoken:")
                        print("1. Open Edge, go to https://www.fantasypros.com/ (make sure you're logged in)")
                        print("2. Press F12 → Application tab → Cookies → https://www.fantasypros.com")
                        print("3. Find 'fptoken' cookie and copy its Value")
                        print("4. Add it to cookies.txt in this format:")
                        print("   fptoken<TAB><value><TAB>.fantasypros.com<TAB>/<TAB>2026-12-31T00:00:00.000Z<TAB>100")
                        print("")
                    
                    return cookies
                else:
                    print("No FantasyPros cookies found in file")
            except Exception as e:
                print(f"Error reading cookie file: {e}")
    
    # Try JSON format
    json_file = script_dir / 'fantasypros_cookies.json'
    if json_file.exists():
        print(f"Found cookie file: {json_file}")
        try:
            with open(json_file, 'r') as f:
                cookies = json.load(f)
            print(f"Loaded {len(cookies)} cookies from JSON file")
            return cookies
        except Exception as e:
            print(f"Error reading JSON cookie file: {e}")
    
    # Try Netscape format (exported from Cookie-Editor)
    txt_file = script_dir / 'fantasypros_cookies.txt'
    if txt_file.exists():
        print(f"Found cookie file: {txt_file}")
        try:
            cookie_jar = MozillaCookieJar(txt_file)
            cookie_jar.load(ignore_discard=True, ignore_expires=True)
            cookies = {cookie.name: cookie.value for cookie in cookie_jar}
            print(f"Loaded {len(cookies)} cookies from Netscape file")
            return cookies
        except Exception as e:
            print(f"Error reading Netscape cookie file: {e}")
    
    return None


def get_browser_cookies():
    """Get cookies from browser for FantasyPros."""
    print("Attempting to load cookies from browser...")
    print("Note: On Windows, this may require running as Administrator\n")
    
    # Try different browsers in order
    browsers = [
        ('Edge', browser_cookie3.edge),
        ('Chrome', browser_cookie3.chrome),
        ('Firefox', browser_cookie3.firefox),
    ]
    
    for browser_name, browser_func in browsers:
        try:
            print(f"Trying {browser_name}...")
            cookies = browser_func(domain_name='fantasypros.com')
            # Check if we actually got cookies
            cookie_list = list(cookies)
            if cookie_list:
                print(f"Successfully loaded {len(cookie_list)} cookies from {browser_name}")
                return cookies
            else:
                print(f"No FantasyPros cookies found in {browser_name}")
        except PermissionError as e:
            print(f"Permission denied for {browser_name}. Try running PowerShell as Administrator.")
        except Exception as e:
            print(f"Could not load from {browser_name}: {e}")
            continue
    
    return None


def get_manual_cookies():
    """Prompt user to manually enter cookie string."""
    print("\n" + "="*50)
    print("MANUAL COOKIE ENTRY")
    print("="*50)
    print("\nTo get your cookies manually:")
    print("1. In Edge, go to https://www.fantasypros.com/")
    print("2. Press F12 to open Developer Tools")
    print("3. Go to the 'Console' tab")
    print("4. Paste this command and press Enter:")
    print("   document.cookie")
    print("5. Copy the entire output (everything between the quotes)")
    print("6. Paste it below\n")
    
    cookie_string = input("Paste your cookie string here (or press Enter to skip): ").strip()
    
    if cookie_string:
        # Parse cookie string into a dictionary
        cookies = {}
        for item in cookie_string.split('; '):
            if '=' in item:
                key, value = item.split('=', 1)
                cookies[key] = value
        return cookies
    return None


def get_synced_leagues(session):
    """Get list of synced leagues from FantasyPros."""
    url = "https://www.fantasypros.com/nfl/myplaybook/"
    
    try:
        response = session.get(url)
        response.raise_for_status()
        
        soup = BeautifulSoup(response.content, 'html.parser')
        
        # Look for league data in the page
        leagues = []
        
        # FantasyPros typically stores league data in JavaScript
        pattern = r'var\s+leagues\s*=\s*(\[.*?\]);'
        match = re.search(pattern, response.text, re.DOTALL)
        
        if match:
            try:
                leagues_data = json.loads(match.group(1))
                for league in leagues_data:
                    leagues.append({
                        'id': league.get('id'),
                        'name': league.get('name'),
                        'platform': league.get('platform')
                    })
            except:
                pass
        
        return leagues
        
    except Exception as e:
        print(f"Error getting leagues: {e}")
        return []


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


def get_synced_leagues_old(session):
    """Get list of synced leagues from FantasyPros (old version)."""
    url = "https://www.fantasypros.com/nfl/myplaybook/"
    
    try:
        response = session.get(url)
        response.raise_for_status()
        
        soup = BeautifulSoup(response.content, 'html.parser')
        
        # Look for league data in the page
        leagues = []
        
        # FantasyPros typically stores league data in JavaScript
        pattern = r'var\s+leagues\s*=\s*(\[.*?\]);'
        match = re.search(pattern, response.text, re.DOTALL)
        
        if match:
            try:
                leagues_data = json.loads(match.group(1))
                for league in leagues_data:
                    leagues.append({
                        'id': league.get('id'),
                        'name': league.get('name'),
                        'platform': league.get('platform')
                    })
            except:
                pass
        
        return leagues
        
    except Exception as e:
        print(f"Error getting leagues: {e}")
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
                    
                    # Now scrape each team's roster
                    all_rosters = []
                    for team_id, team_info in league_teams.items():
                        team_name = team_info.get('text', 'Unknown Team')
                        print(f"\nScraping roster for: {team_name} (Team ID: {team_id})")
                        
                        team_url = f"{my_team_url}?team={team_id}"
                        team_response = session.get(team_url)
                        
                        if team_response.status_code == 200:
                            team_roster = parse_team_roster_html(team_response.text, team_name)
                            all_rosters.extend(team_roster)
                            print(f"  Found {len(team_roster)} players")
                        else:
                            print(f"  Failed to fetch team page: {team_response.status_code}")
                    
                    if all_rosters:
                        return all_rosters
                        
                except Exception as e:
                    print(f"Error parsing team settings: {e}")
            
    except Exception as e:
        print(f"Error checking my-team page: {e}")
    
    # First try the API endpoint with proper headers
    api_url = f"https://api.fantasypros.com/v2/leagues/rosters.php?key={league_key}"
    headers = {
        'Accept': 'application/json',
        'Referer': f'https://www.fantasypros.com/nfl/myleagues/?key={league_key}',
        'X-Requested-With': 'XMLHttpRequest',
    }
    
    print(f"\nTrying API endpoint: {api_url}")
    try:
        response = session.get(api_url, headers=headers)
        print(f"API Status: {response.status_code}")
        
        if response.status_code == 200:
            print("Success with API!")
            # Save the JSON response
            debug_file = Path(__file__).parent / 'fantasypros_roster_api_response.json'
            with open(debug_file, 'w', encoding='utf-8') as f:
                f.write(response.text)
            print(f"Saved API response to: {debug_file}")
            
            try:
                data = response.json()
                return parse_roster_json(data)
            except Exception as e:
                print(f"Error parsing JSON: {e}")
    except Exception as e:
        print(f"API request failed: {e}")
    
    # Fall back to trying multiple web page URLs
    urls_to_try = [
        f"https://www.fantasypros.com/nfl/myleagues/rosters.php?key={league_key}",
        f"https://www.fantasypros.com/nfl/myleagues/league-rosters.php?key={league_key}",
        f"https://www.fantasypros.com/nfl/myplaybook/rosters.php?key={league_key}",
        f"https://www.fantasypros.com/nfl/myleagues/rosters/?key={league_key}",
        f"https://www.fantasypros.com/nfl/myleagues/?key={league_key}",
    ]
    
    url = None
    response = None
    
    for test_url in urls_to_try:
        try:
            print(f"Trying URL: {test_url}")
            test_response = session.get(test_url)
            if test_response.status_code == 200:
                url = test_url
                response = test_response
                print(f"Success! Using: {url}")
                break
            else:
                print(f"Status {test_response.status_code}")
        except Exception as e:
            print(f"Failed: {e}")
            continue
    
    if not url or not response:
        print("Could not find a valid roster URL")
        return []
    
    rosters = []
    
    try:
        print(f"Roster page status: {response.status_code}")
        
        # Save the HTML for debugging
        debug_file = Path(__file__).parent / 'fantasypros_league_page.html'
        with open(debug_file, 'w', encoding='utf-8') as f:
            f.write(response.text)
        print(f"Saved page HTML to: {debug_file}")
        
        soup = BeautifulSoup(response.content, 'html.parser')
        
        # Look for roster data - FantasyPros often uses tables or divs
        # Check for JSON data first
        pattern = r'var\s+rosterData\s*=\s*(\{.*?\});'
        match = re.search(pattern, response.text, re.DOTALL)
        
        if match:
            try:
                roster_data = json.loads(match.group(1))
                print("Found roster data in JSON")
                
                # Parse the roster data structure
                if 'teams' in roster_data:
                    for team in roster_data['teams']:
                        team_name = team.get('name', 'Unknown Team')
                        
                        if 'roster' in team or 'players' in team:
                            players = team.get('roster', team.get('players', []))
                            
                            for player in players:
                                rosters.append({
                                    'team_name': team_name,
                                    'player_name': player.get('name', ''),
                                    'position': player.get('position', '')
                                })
                
            except json.JSONDecodeError as e:
                print(f"Error parsing JSON: {e}")
        
        # If no JSON data, try parsing HTML tables
        if not rosters:
            print("Trying to parse HTML tables...")
            
            # Look for team containers
            team_containers = soup.find_all(['div', 'table'], class_=re.compile(r'team|roster', re.I))
            
            for container in team_containers:
                # Try to find team name
                team_name_elem = container.find(['h2', 'h3', 'span'], class_=re.compile(r'team.*name', re.I))
                team_name = team_name_elem.get_text(strip=True) if team_name_elem else "Unknown Team"
                
                # Find player rows
                player_rows = container.find_all('tr')
                
                for row in player_rows:
                    player_link = row.find('a', class_=re.compile(r'player', re.I))
                    
                    if player_link:
                        player_name = player_link.get_text(strip=True)
                        
                        # Try to find position
                        pos_elem = row.find(['td', 'span'], class_=re.compile(r'pos', re.I))
                        position = pos_elem.get_text(strip=True) if pos_elem else ""
                        
                        rosters.append({
                            'team_name': team_name,
                            'player_name': player_name,
                            'position': position
                        })
        
        return rosters
        
    except Exception as e:
        print(f"Error scraping rosters: {e}")
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
    fptoken = "gAAAAABpBdnv3uiz6MOot7jZXG2iJYih12RN_159tvaSQfnMDthOTQVWLf0FN8wwQ2mQp2JmMgRLFP91xfNz1o9B8--_mzsgRztMW_n3sxYdgvyNLUSzaY4%3D%3A1762016358"
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
