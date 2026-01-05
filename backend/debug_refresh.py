import asyncio
import os
from dotenv import load_dotenv
import httpx
import base64

load_dotenv()

async def test_refresh():
    client_id = os.getenv("SPOTIFY_CLIENT_ID")
    client_secret = os.getenv("SPOTIFY_CLIENT_SECRET")
    refresh_token = os.getenv("ASTROFM_SPOTIFY_REFRESH_TOKEN")
    
    print(f"ID: {client_id[:5]}...")
    print(f"Secret: {client_secret[:5]}...")
    print(f"Token: {refresh_token[:5]}...")
    
    auth_header = base64.b64encode(f"{client_id}:{client_secret}".encode()).decode()
    
    async with httpx.AsyncClient() as client:
        response = await client.post(
            "https://accounts.spotify.com/api/token",
            headers={
                "Authorization": f"Basic {auth_header}",
                "Content-Type": "application/x-www-form-urlencoded",
            },
            data={
                "grant_type": "refresh_token",
                "refresh_token": refresh_token,
            },
        )
        print(f"Status: {response.status_code}")
        print(f"Body: {response.text}")

if __name__ == "__main__":
    asyncio.run(test_refresh())
