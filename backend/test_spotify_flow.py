"""
Test script to fetch user's Spotify library and get audio features.
This demonstrates the full flow with a connected Spotify account.
"""
import httpx
import asyncio

SESSION_ID = "GDEnoUoW-9Rt81sNQOjbs3nGS8hNnqpTWuBMmQ2VpXk"
BASE_URL = "http://127.0.0.1:8000"


async def main():
    print("=" * 60)
    print("Testing Spotify Integration with RapidAPI Audio Features")
    print("=" * 60)
    
    async with httpx.AsyncClient(timeout=60.0) as client:
        # Step 1: Check connection
        print("\n1. Checking Spotify connection...")
        status = await client.get(f"{BASE_URL}/api/spotify/status?session_id={SESSION_ID}")
        status_data = status.json()
        print(f"   Connected: {status_data['connected']}")
        print(f"   User: {status_data.get('display_name', 'Unknown')}")
        
        if not status_data['connected']:
            print("   ERROR: Not connected to Spotify!")
            return
        
        # Step 2: Generate a playlist from library (this uses the integrated audio features)
        print("\n2. Fetching your saved tracks and generating playlist...")
        print("   (This will fetch tracks and get audio features via RapidAPI)")
        
        request_body = {
            "session_id": SESSION_ID,
            "name": "ASTRO.FM Test Playlist",
            "energy_target": 0.7,
            "mood_target": 0.6,
            "playlist_size": 5
        }
        
        response = await client.post(
            f"{BASE_URL}/api/spotify/generate-from-library",
            json=request_body
        )
        
        if response.status_code == 200:
            result = response.json()
            print(f"\n   ✅ Success!")
            print(f"   Playlist created: {result.get('playlist_url', 'N/A')}")
            print(f"   Tracks added: {result.get('tracks_added', 0)}")
        else:
            print(f"   Status: {response.status_code}")
            print(f"   Response: {response.text}")
        
        # Step 3: Check cache stats
        print("\n3. Checking audio features cache...")
        cache_response = await client.get(f"{BASE_URL}/api/spotify/audio-features-cache/stats")
        cache_data = cache_response.json()
        print(f"   Cached tracks: {cache_data['cached_tracks']}")
        print(f"   API configured: {cache_data['api_configured']}")


if __name__ == "__main__":
    asyncio.run(main())
