import asyncio
import os
from services.cosmic.app_spotify import get_app_spotify_service

async def test_spotify():
    print("Testing Spotify Search...")
    spotify = get_app_spotify_service()
    try:
        result = await spotify.search_track('track:"Bohemian Rhapsody" artist:"Queen"')
        if result:
            print(f"Success! Found: {result['name']} by {result['artists'][0]['name']}")
        else:
            print("No results found.")
    except Exception as e:
        print(f"Error during search: {type(e).__name__}: {e}")

if __name__ == "__main__":
    asyncio.run(test_spotify())
