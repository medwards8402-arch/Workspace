"""
Spotify Top Tracks Export
Pulls user's top tracks across time ranges and writes them to CSV.
Requires Authorization Code flow (user login) for personal data access.

Before running:
  1. Go to https://developer.spotify.com/dashboard
  2. Select your app and go to Settings
  3. Add http://localhost:8888/callback as a Redirect URI
"""

import csv
import os
import webbrowser
import requests
import base64
import urllib.parse
from http.server import HTTPServer, BaseHTTPRequestHandler
from datetime import datetime


# Configuration
CLIENT_ID = "f689094b6fab4852b02117114b71a31a"
CLIENT_SECRET = "75203d8edf014530b98b6f865554043c"
REDIRECT_URI = "http://127.0.0.1:8888/callback"
TOKEN_URL = "https://accounts.spotify.com/api/token"
AUTH_URL = "https://accounts.spotify.com/authorize"
BASE_API_URL = "https://api.spotify.com/v1"

SCOPES = "user-top-read playlist-modify-public playlist-modify-private"

OUTPUT_DIR = os.path.dirname(os.path.abspath(__file__))

# Time range to fetch
TIME_RANGE = "long_term"
TIME_RANGE_LABEL = "All Time"
TOP_N = 150


# ============================================================================
# Authorization Helper Functions
# ============================================================================

class CallbackHandler(BaseHTTPRequestHandler):
    """HTTP handler to capture the OAuth callback."""

    auth_code = None

    def do_GET(self):
        """Handle the redirect from Spotify."""
        query = urllib.parse.urlparse(self.path).query
        params = urllib.parse.parse_qs(query)

        if "code" in params:
            CallbackHandler.auth_code = params["code"][0]
            self.send_response(200)
            self.send_header("Content-Type", "text/html")
            self.end_headers()
            self.wfile.write(
                b"<html><body><h2>Authorization successful!</h2>"
                b"<p>You can close this window and return to the terminal.</p>"
                b"</body></html>"
            )
        else:
            error = params.get("error", ["Unknown error"])[0]
            self.send_response(400)
            self.send_header("Content-Type", "text/html")
            self.end_headers()
            self.wfile.write(
                f"<html><body><h2>Authorization failed: {error}</h2></body></html>".encode()
            )

    def log_message(self, format, *args):
        """Suppress default request logging."""
        pass


def get_auth_header():
    """
    Generate the Base64-encoded authorization header for client credentials.

    Returns:
        str: Base64-encoded string of client_id:client_secret
    """
    credentials = f"{CLIENT_ID}:{CLIENT_SECRET}"
    return base64.b64encode(credentials.encode()).decode()


def open_auth_page():
    """
    Open the Spotify authorization page in the user's browser.
    """
    params = {
        "client_id": CLIENT_ID,
        "response_type": "code",
        "redirect_uri": REDIRECT_URI,
        "scope": SCOPES,
        "show_dialog": "true",
    }
    auth_url = f"{AUTH_URL}?{urllib.parse.urlencode(params)}"
    print(f"Redirect URI: {REDIRECT_URI}")
    print(f"Full auth URL:\n{auth_url}")
    print("\nOpening browser for Spotify login...")
    webbrowser.open(auth_url)


def wait_for_callback():
    """
    Start a local HTTP server and wait for the OAuth callback.

    Returns:
        str: Authorization code from Spotify, or None if failed
    """
    server = HTTPServer(("127.0.0.1", 8888), CallbackHandler)
    server.timeout = 120  # 2 minute timeout
    print("Waiting for authorization (check your browser)...")
    server.handle_request()
    return CallbackHandler.auth_code


def exchange_code_for_token(auth_code):
    """
    Exchange an authorization code for access and refresh tokens.

    Args:
        auth_code (str): Authorization code from callback

    Returns:
        dict: Token data including access_token and refresh_token, or None
    """
    headers = {
        "Authorization": f"Basic {get_auth_header()}",
        "Content-Type": "application/x-www-form-urlencoded",
    }
    data = {
        "grant_type": "authorization_code",
        "code": auth_code,
        "redirect_uri": REDIRECT_URI,
    }

    response = requests.post(TOKEN_URL, headers=headers, data=data)

    if response.status_code == 200:
        return response.json()
    else:
        print(f"Error exchanging code: {response.status_code}")
        print(response.json())
        return None


def authorize():
    """
    Run the full authorization flow: open browser, wait for callback, get token.

    Returns:
        str: Access token, or None if authorization failed
    """
    open_auth_page()
    auth_code = wait_for_callback()

    if not auth_code:
        print("No authorization code received.")
        return None

    print("Authorization code received. Exchanging for token...")
    token_data = exchange_code_for_token(auth_code)

    if token_data:
        print("Successfully authenticated!")
        # Debug: show granted scopes
        print(f"  Scopes granted: {token_data.get('scope', 'none')}")
        return token_data.get("access_token")
    return None


def get_auth_headers(token):
    """
    Generate the authorization headers for API requests.

    Args:
        token (str): Access token

    Returns:
        dict: Headers dictionary with Bearer token
    """
    return {"Authorization": f"Bearer {token}"}


def make_api_request(endpoint, token, params=None):
    """
    Make a GET request to the Spotify API.

    Args:
        endpoint (str): API endpoint (without base URL)
        token (str): Access token
        params (dict, optional): Query parameters

    Returns:
        dict: JSON response, or None if request fails
    """
    url = f"{BASE_API_URL}/{endpoint}"
    headers = get_auth_headers(token)

    response = requests.get(url, headers=headers, params=params)

    if response.status_code == 200:
        return response.json()
    else:
        print(f"API Error: {response.status_code}")
        print(response.json())
        return None


# ============================================================================
# Data Retrieval
# ============================================================================

def get_top_tracks(token, time_range="long_term", total=150):
    """
    Get the user's top tracks for a given time range.
    Handles pagination since the API max per request is 50.

    Args:
        token (str): Access token
        time_range (str): short_term, medium_term, or long_term
        total (int): Total number of tracks to fetch

    Returns:
        list: List of track objects
    """
    all_tracks = []
    offset = 0

    while offset < total:
        limit = min(50, total - offset)
        params = {"time_range": time_range, "limit": limit, "offset": offset}
        result = make_api_request("me/top/tracks", token, params)

        if result and result.get("items"):
            all_tracks.extend(result["items"])
            offset += len(result["items"])
            # Stop if we got fewer than requested (no more data)
            if len(result["items"]) < limit:
                break
        else:
            break

    return all_tracks


def extract_track_data(track, rank, time_range_label):
    """
    Extract relevant fields from a track object for CSV output.

    Args:
        track (dict): Spotify track object
        rank (int): Position in the top list
        time_range_label (str): Human-readable time range label

    Returns:
        dict: Flattened track data
    """
    artists = ", ".join(a["name"] for a in track.get("artists", []))
    return {
        "rank": rank,
        "time_range": time_range_label,
        "title": track.get("name", ""),
        "artist": artists,
        "album": track.get("album", {}).get("name", ""),
        "popularity": track.get("popularity", ""),
        "duration_ms": track.get("duration_ms", ""),
        "track_id": track.get("id", ""),
        "track_uri": track.get("uri", ""),
        "album_id": track.get("album", {}).get("id", ""),
        "external_url": track.get("external_urls", {}).get("spotify", ""),
    }


# ============================================================================
# CSV Export
# ============================================================================

def write_tracks_to_csv(all_tracks, filepath):
    """
    Write track data to a CSV file.

    Args:
        all_tracks (list[dict]): List of extracted track data dicts
        filepath (str): Output file path
    """
    if not all_tracks:
        print("No tracks to write.")
        return

    fieldnames = [
        "rank",
        "time_range",
        "title",
        "artist",
        "album",
        "popularity",
        "duration_ms",
        "track_id",
        "track_uri",
        "album_id",
        "external_url",
    ]

    with open(filepath, "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(all_tracks)

    print(f"\nWrote {len(all_tracks)} tracks to {filepath}")


# ============================================================================
# Playlist Creation
# ============================================================================

def get_user_id(token):
    """
    Get the current user's Spotify user ID.

    Args:
        token (str): Access token

    Returns:
        str: User ID, or None if request fails
    """
    result = make_api_request("me", token)
    if result:
        return result.get("id")
    return None


def create_playlist(token, user_id, name, description=""):
    """
    Create a new playlist for the user.

    Args:
        token (str): Access token
        user_id (str): Spotify user ID
        name (str): Playlist name
        description (str): Playlist description

    Returns:
        str: Playlist ID, or None if creation fails
    """
    url = f"{BASE_API_URL}/users/{user_id}/playlists"
    headers = get_auth_headers(token)
    headers["Content-Type"] = "application/json"

    payload = {
        "name": name,
    }
    
    if description:
        payload["description"] = description

    print(f"  POST {url}")
    print(f"  Payload: {payload}")
    response = requests.post(url, headers=headers, json=payload)

    if response.status_code in (200, 201):
        playlist = response.json()
        print(f"Created playlist: {playlist['name']} ({playlist['external_urls']['spotify']})")
        return playlist.get("id")
    else:
        print(f"Error creating playlist: {response.status_code}")
        print(f"Response headers: {dict(response.headers)}")
        print(f"Response body: {response.text}")
        return None


def add_tracks_to_playlist(token, playlist_id, track_uris):
    """
    Add tracks to a playlist. Handles batching (max 100 per request).

    Args:
        token (str): Access token
        playlist_id (str): Spotify playlist ID
        track_uris (list): List of track URIs (e.g. spotify:track:xxx)

    Returns:
        bool: True if all tracks were added successfully
    """
    url = f"{BASE_API_URL}/playlists/{playlist_id}/tracks"
    headers = get_auth_headers(token)
    headers["Content-Type"] = "application/json"

    # API allows max 100 tracks per request
    for i in range(0, len(track_uris), 100):
        batch = track_uris[i:i + 100]
        response = requests.post(url, headers=headers, json={"uris": batch})

        if response.status_code not in (200, 201):
            print(f"Error adding tracks (batch starting at {i}): {response.status_code}")
            print(response.json())
            return False

        print(f"  Added tracks {i + 1}-{i + len(batch)}")

    return True


# ============================================================================
# Main
# ============================================================================

def main():
    """Pull top tracks across all time ranges and export to CSV."""

    # Authorize with user login
    print("=" * 50)
    print("Spotify Top Tracks Export")
    print("=" * 50)
    token = authorize()

    if not token:
        print("Failed to authenticate. Exiting.")
        return

    # Collect top tracks
    all_tracks = []

    print(f"\nFetching top {TOP_N} tracks - {TIME_RANGE_LABEL}...")
    tracks = get_top_tracks(token, time_range=TIME_RANGE, total=TOP_N)

    if tracks:
        print(f"  Found {len(tracks)} tracks")
        for i, track in enumerate(tracks, 1):
            data = extract_track_data(track, i, TIME_RANGE_LABEL)
            all_tracks.append(data)

            # Display in console
            print(f"  {i:>3}. {data['title']} - {data['artist']}")
    else:
        print(f"  No tracks found")

    # Write to CSV
    timestamp = datetime.now().strftime("%Y%m%d")
    filename = f"top_tracks_{timestamp}.csv"
    filepath = os.path.join(OUTPUT_DIR, filename)
    write_tracks_to_csv(all_tracks, filepath)

    # Write track URIs to a text file for pasting into Spotify
    if all_tracks:
        uri_filename = f"top_tracks_uris_{timestamp}.txt"
        uri_filepath = os.path.join(OUTPUT_DIR, uri_filename)
        track_uris = [t["track_uri"] for t in all_tracks if t.get("track_uri")]

        with open(uri_filepath, "w", encoding="utf-8") as f:
            f.write("\n".join(track_uris))

        print(f"Wrote {len(track_uris)} track URIs to {uri_filepath}")
        print("\nTo create a playlist:")
        print("  1. Open Spotify desktop app")
        print("  2. Create a new playlist")
        print(f"  3. Open {uri_filename}, select all (Ctrl+A), copy (Ctrl+C)")
        print("  4. Click inside the playlist and paste (Ctrl+V)")


if __name__ == "__main__":
    main()
