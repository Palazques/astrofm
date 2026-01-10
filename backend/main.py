"""
Astro.FM Backend API
FastAPI application for astrological calculations using Swiss Ephemeris.
"""
import os
import sys
import io
from pathlib import Path
from contextlib import asynccontextmanager
from dotenv import load_dotenv

# Fix Windows console encoding for Unicode characters (zodiac symbols, etc.)
if sys.platform == 'win32':
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')
    sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding='utf-8', errors='replace')

# CRITICAL: Load environment variables BEFORE importing routes
env_path = Path(__file__).parent / ".env"
load_dotenv(env_path)

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from api.routes.charts import router as charts_router
from api.routes.geocoding import router as geocoding_router
from api.routes.sonification import router as sonification_router
from api.routes.ai import router as ai_router
from api.routes.playlist import router as playlist_router
from api.routes.playlist_export import router as playlist_export_router
from api.routes.alignment import router as alignment_router
from api.routes.spotify import router as spotify_router
from api.routes.attunement import router as attunement_router
from api.routes.prescription import router as prescription_router
from api.routes.user_library import router as user_library_router
from api.routes.cosmic_playlist import router as cosmic_router
from api.routes.discover import router as discover_router
from models.schemas import HealthResponse
from services.ephemeris import init_ephemeris, check_ephemeris_available

API_VERSION = "0.1.0"

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup: Initialize Swiss Ephemeris
    init_ephemeris()
    yield
    # Shutdown logic if needed
    pass

app = FastAPI(
    title="Astro.FM API",
    description="Astrological calculation and interpretation engine",
    version=API_VERSION,
    lifespan=lifespan
)

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Adjust in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include all routers with their API prefixes
app.include_router(charts_router, prefix="/api/charts")
app.include_router(geocoding_router, prefix="/api/geocode")
app.include_router(sonification_router, prefix="/api/sonification")
app.include_router(ai_router, prefix="/api/ai")
app.include_router(playlist_router, prefix="/api/playlist")
app.include_router(playlist_export_router, prefix="/api/playlist")
app.include_router(alignment_router, prefix="/api/alignment")
app.include_router(spotify_router, prefix="/api/spotify")
app.include_router(attunement_router, prefix="/api/attunement")
app.include_router(prescription_router, prefix="/api/prescription")
app.include_router(user_library_router, prefix="/api/user-library")
app.include_router(cosmic_router, prefix="/api/cosmic")
app.include_router(discover_router, prefix="/api/discover")

@app.get("/health", response_model=HealthResponse, tags=["system"])
async def health_check() -> HealthResponse:
    """
    Health check endpoint to verify API status.
    """
    return HealthResponse(
        status="healthy",
        version=API_VERSION,
        ephemeris_available=check_ephemeris_available()
    )

@app.get("/", tags=["system"])
async def root():
    """
    Root endpoint with API info.
    """
    return {
        "name": "Astro.FM API",
        "version": API_VERSION,
        "docs": "/docs",
        "health": "/health"
    }

if __name__ == "__main__":
    import uvicorn
    
    host = os.getenv("HOST", "0.0.0.0")
    port = int(os.getenv("PORT", 8000))
    debug = os.getenv("DEBUG", "true").lower() == "true"
    
    uvicorn.run(
        "main:app",
        host=host,
        port=port,
        reload=debug
    )
