# NFL Scripts

This directory contains scripts for scraping and analyzing NFL fantasy football data.

## Scripts

### scrape_league_rosters.py

Scrapes roster information from FantasyPros to determine which players are on which teams in your fantasy league.

**Output**: `league_rosters.csv` - Contains team names, player names, and positions for all players in the league.

## Configuration

The script requires authentication with FantasyPros using the `fptoken` cookie, which is hardcoded directly in the script.

### Getting Your fptoken Cookie

1. In your browser (Edge, Chrome, etc.), go to https://www.fantasypros.com/ and log in
2. Press F12 to open Developer Tools
3. Go to the **Application** tab → **Cookies** → `https://www.fantasypros.com`
4. Find the cookie named `fptoken`
5. Copy its **Value** (will be a long encrypted string starting with `gAAAAAB...`)
6. Open `scrape_league_rosters.py` and replace the `fptoken` value in the `main()` function:

```python
# Around line 535 in scrape_league_rosters.py
fptoken = "gAAAAAB...your_token_here..."
session.cookies.set('fptoken', fptoken, domain='.fantasypros.com', path='/')
```

### Getting Your League Key

1. Go to your league on FantasyPros: https://www.fantasypros.com/nfl/myleagues/
2. Click on your league
3. The URL will contain your league key in this format: `?key=nfl~XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX`
4. Copy the entire key (including the `nfl~` prefix)
5. Update the `league_key` variable in `scrape_league_rosters.py`:

```python
# Around line 543 in scrape_league_rosters.py
league_key = "nfl~your-league-key-here"
```

## Usage

```powershell
python NFL\scrape_league_rosters.py
```

The script will output roster data for all teams to `league_rosters.csv`.
