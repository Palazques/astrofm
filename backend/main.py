"""
Astro.FM Backend API
FastAPI application for astrological calculations using Swiss Ephemeris.
"""
import os
from contextlib import asynccontextmanager
from dotenv import load_dotenv
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from api.routes.charts import router as charts_router
from api.routes.geocoding import router as geocoding_router
from api.routes.sonification import router as sonification_router
from api.routes.ai import router as ai_router
from models.schemas import HealthResponse
from services.ephemeris import init_ephemeris, check_ephemeris_available

# Load environment variables
load_dotenv()

# API version
API_VERSION = "0.1.0"


@asynccontextmanager
async def lifespan(app: FastAPI):
    """
    Application lifespan handler for startup/shutdown events.
    """
    # Startup: Initialize Swiss Ephemeris
    ephe_path = os.getenv("EPHE_PATH")
    init_ephemeris(ephe_path)
    print(f"[*] Astro.FM Backend v{API_VERSION} started")
    print(f"[*] Swiss Ephemeris initialized: {check_ephemeris_available()}")
    
    yield
    
    # Shutdown
    print("[*] Astro.FM Backend shutting down")


# Create FastAPI app
app = FastAPI(
    title="Astro.FM API",
    description="Backend API for astrological calculations and data sonification",
    version=API_VERSION,
    lifespan=lifespan
)

# Configure CORS for Flutter app communication
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:3000",      # Flutter web dev
        "http://localhost:8080",      # Alternative Flutter web
        "http://127.0.0.1:3000",
        "http://127.0.0.1:8080",
        "*"  # Allow all for development - restrict in production
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(charts_router)
app.include_router(geocoding_router)
app.include_router(sonification_router)
app.include_router(ai_router)


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
