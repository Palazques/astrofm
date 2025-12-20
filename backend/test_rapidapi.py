"""
Test script for RapidAPI Track Analysis API.

Tests the API with sample tracks using the correct endpoints discovered from docs:
- GET /pktx/spotify/{spotify_id} - Get by Spotify ID
- GET /pktx/analysis?song=X&artist=Y - Get by query
"""
import httpx
import asyncio
import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

RAPIDAPI_KEY = os.getenv("RAPIDAPI_KEY")
RAPIDAPI_HOST = os.getenv("RAPIDAPI_HOST", "track-analysis.p.rapidapi.com")

# Test tracks from our mock library (with likely Spotify IDs)
TEST_TRACKS = [
    {"title": "Blinding Lights", "artist": "The Weeknd", "spotify_id": "0VjIjW4GlUZAMYd2vXMi3b"},
    {"title": "Lose Yourself", "artist": "Eminem", "spotify_id": "1v7L65Lc0Ig9DwoG3xbNgN"},  
    {"title": "Skinny Love", "artist": "Bon Iver", "spotify_id": "7s25THrKz86DM225dOYwnr"},
]


async def test_by_spotify_id(spotify_id: str, title: str):
    """Test the /pktx/spotify/{id} endpoint."""
    print(f"\n{'='*60}")
    print(f"Testing BY SPOTIFY ID: '{title}' (ID: {spotify_id})")
    print('='*60)
    
    if not RAPIDAPI_KEY:
        print("ERROR: RAPIDAPI_KEY not found in environment!")
        return None
    
    headers = {
        "x-rapidapi-key": RAPIDAPI_KEY,
        "x-rapidapi-host": RAPIDAPI_HOST,
    }
    
    base_url = f"https://{RAPIDAPI_HOST}"
    url = f"{base_url}/pktx/spotify/{spotify_id}"
    
    async with httpx.AsyncClient(timeout=30.0) as client:
        try:
            print(f"GET {url}")
            response = await client.get(url, headers=headers)
            print(f"Status: {response.status_code}")
            
            if response.status_code == 200:
                data = response.json()
                print(f"\nSUCCESS! Response:")
                for key, value in data.items():
                    print(f"  {key}: {value}")
                return data
            else:
                print(f"Response: {response.text[:500]}")
        except Exception as e:
            print(f"Error: {e}")
    
    return None


async def test_by_query(title: str, artist: str):
    """Test the /pktx/analysis endpoint."""
    print(f"\n{'='*60}")
    print(f"Testing BY QUERY: '{title}' by {artist}")
    print('='*60)
    
    if not RAPIDAPI_KEY:
        print("ERROR: RAPIDAPI_KEY not found in environment!")
        return None
    
    headers = {
        "x-rapidapi-key": RAPIDAPI_KEY,
        "x-rapidapi-host": RAPIDAPI_HOST,
    }
    
    base_url = f"https://{RAPIDAPI_HOST}"
    url = f"{base_url}/pktx/analysis"
    params = {"song": title, "artist": artist}
    
    async with httpx.AsyncClient(timeout=30.0) as client:
        try:
            print(f"GET {url}")
            print(f"Params: {params}")
            response = await client.get(url, headers=headers, params=params)
            print(f"Status: {response.status_code}")
            
            if response.status_code == 200:
                data = response.json()
                print(f"\nSUCCESS! Response:")
                for key, value in data.items():
                    print(f"  {key}: {value}")
                return data
            else:
                print(f"Response: {response.text[:500]}")
        except Exception as e:
            print(f"Error: {e}")
    
    return None


async def main():
    print("="*60)
    print("RapidAPI Track Analysis - Test Script")
    print(f"API Host: {RAPIDAPI_HOST}")
    print(f"API Key: {'SET' if RAPIDAPI_KEY else 'NOT SET'}")
    print("="*60)
    
    # Test with first track using query method
    track = TEST_TRACKS[0]
    result = await test_by_query(track["title"], track["artist"])
    
    if not result:
        print("\n*** Query method failed. Trying Spotify ID method... ***")
        result = await test_by_spotify_id(track["spotify_id"], track["title"])
    
    if result:
        # Show how we'd map to our format
        print("\n" + "="*60)
        print("MAPPING TO ASTRO.FM FORMAT:")
        print("="*60)
        print(f"  energy:       {result.get('energy', 0) / 100:.2f}")  # 0-100 -> 0-1
        print(f"  valence:      {result.get('happiness', 0) / 100:.2f}")  # happiness -> valence
        print(f"  tempo:        {result.get('tempo', 0)} BPM")
        print(f"  danceability: {result.get('danceability', 0) / 100:.2f}")


if __name__ == "__main__":
    asyncio.run(main())
