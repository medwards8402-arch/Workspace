"""
Spotify API Client
Basic script to pull data from the Spotify API using Client Credentials flow.
"""

import requests
import base64


# Configuration
CLIENT_ID = "f689094b6fab4852b02117114b71a31a"
CLIENT_SECRET = "75203d8edf014530b98b6f865554043c"
TOKEN_URL = "https://accounts.spotify.com/api/token"
BASE_API_URL = "https://api.spotify.com/v1"


# ============================================================================
# Connection Helper Functions
# ============================================================================

def get_auth_header():
    """
    Generate the Base64-encoded authorization header for client credentials.
    
    Returns:
        str: Base64-encoded string of client_id:client_secret
    """
    credentials = f"{CLIENT_ID}:{CLIENT_SECRET}"
    encoded = base64.b64encode(credentials.encode()).decode()
    return encoded


def get_access_token():
    """
    Request an access token from Spotify using Client Credentials flow.
    
    Returns:
        str: Access token for API requests, or None if request fails
    """
    auth_header = get_auth_header()
    
    headers = {
        "Authorization": f"Basic {auth_header}",
        "Content-Type": "application/x-www-form-urlencoded"
    }
    
    data = {
        "grant_type": "client_credentials"
    }
    
    response = requests.post(TOKEN_URL, headers=headers, data=data)
    
    if response.status_code == 200:
        token_data = response.json()
        return token_data.get("access_token")
    else:
        print(f"Error getting access token: {response.status_code}")
        print(response.json())
        return None


def get_auth_headers(token):
    """
    Generate the authorization headers for API requests.
    
    Args:
        token (str): Access token from Spotify
        
    Returns:
        dict: Headers dictionary with Bearer token
    """
    return {
        "Authorization": f"Bearer {token}"
    }


def make_api_request(endpoint, token, params=None):
    """
    Make a GET request to the Spotify API.
    
    Args:
        endpoint (str): API endpoint (without base URL)
        token (str): Access token
        params (dict, optional): Query parameters
        
    Returns:
        dict: JSON response from API, or None if request fails
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
# Data Retrieval Functions
# ============================================================================

def search_artist(token, artist_name):
    """
    Search for an artist by name.
    
    Args:
        token (str): Access token
        artist_name (str): Name of artist to search for
        
    Returns:
        dict: Artist data or None if not found
    """
    params = {
        "q": artist_name,
        "type": "artist",
        "limit": 1
    }
    
    result = make_api_request("search", token, params)
    
    if result and result.get("artists", {}).get("items"):
        return result["artists"]["items"][0]
    return None


def get_artist_albums(token, artist_id, limit=10):
    """
    Get an artist's albums.
    
    Args:
        token (str): Access token
        artist_id (str): Spotify artist ID
        limit (int): Number of albums to return (default: 10)
        
    Returns:
        list: List of albums
    """
    endpoint = f"artists/{artist_id}/albums"
    params = {"limit": limit, "include_groups": "album"}
    
    result = make_api_request(endpoint, token, params)
    
    if result:
        return result.get("items", [])
    return []


def get_artist_details(token, artist_id):
    """
    Get full artist details by ID.
    
    Args:
        token (str): Access token
        artist_id (str): Spotify artist ID
        
    Returns:
        dict: Full artist data
    """
    return make_api_request(f"artists/{artist_id}", token)


def get_album_tracks(token, album_id):
    """
    Get tracks from an album.
    
    Args:
        token (str): Access token
        album_id (str): Spotify album ID
        
    Returns:
        list: List of tracks
    """
    result = make_api_request(f"albums/{album_id}/tracks", token)
    
    if result:
        return result.get("items", [])
    return []


def get_album(token, album_id):
    """
    Get album details by ID.
    
    Args:
        token (str): Access token
        album_id (str): Spotify album ID
        
    Returns:
        dict: Album data
    """
    return make_api_request(f"albums/{album_id}", token)


def get_track(token, track_id):
    """
    Get track details by ID.
    
    Args:
        token (str): Access token
        track_id (str): Spotify track ID
        
    Returns:
        dict: Track data
    """
    return make_api_request(f"tracks/{track_id}", token)


# ============================================================================
# Main Example
# ============================================================================

def main():
    """Main function demonstrating basic API usage."""
    
    # Get access token
    print("Connecting to Spotify API...")
    token = get_access_token()
    
    if not token:
        print("Failed to connect to Spotify API")
        return
    
    print("Successfully connected!\n")
    
    # Example: Search for an artist
    artist_name = "Radiohead"
    print(f"Searching for artist: {artist_name}")
    artist = search_artist(token, artist_name)
    
    if artist:
        # Fetch full artist details for complete data
        artist = get_artist_details(token, artist['id']) or artist
        
        print(f"\nFound: {artist['name']}")
        genres = artist.get('genres', [])
        print(f"Genres: {', '.join(genres) if genres else 'Unknown'}")
        followers = artist.get('followers', {}).get('total')
        print(f"Followers: {followers:,}" if followers else "Followers: Unknown")
        print(f"Popularity: {artist.get('popularity', 'Unknown')}")
        
        # Get albums
        print(f"\nAlbums by {artist['name']}:")
        print("-" * 40)
        
        albums = get_artist_albums(token, artist['id'])
        for i, album in enumerate(albums[:5], 1):
            print(f"{i}. {album['name']} ({album.get('release_date', 'Unknown')[:4]})")
        
        # Show tracks from first album
        if albums:
            first_album = albums[0]
            print(f"\nTracks on \"{first_album['name']}\":")
            print("-" * 40)
            tracks = get_album_tracks(token, first_album['id'])
            for i, track in enumerate(tracks, 1):
                mins, secs = divmod(track.get('duration_ms', 0) // 1000, 60)
                print(f"{i}. {track['name']} ({mins}:{secs:02d})")
    else:
        print(f"Artist '{artist_name}' not found")


if __name__ == "__main__":
    main()
