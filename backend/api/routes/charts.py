"""
Chart calculation API routes.
"""
from datetime import datetime
from zoneinfo import ZoneInfo
from fastapi import APIRouter, HTTPException

from models.schemas import BirthDataRequest, NatalChartResponse, PlanetPosition
from services.ephemeris import calculate_natal_chart

router = APIRouter(tags=["charts"])


@router.post("/natal", response_model=NatalChartResponse)
async def create_natal_chart(birth_data: BirthDataRequest) -> NatalChartResponse:
    """
    Calculate a natal chart from birth data.
    
    Args:
        birth_data: Birth date, time, and location
        
    Returns:
        Complete natal chart with planetary positions
    """
    try:
        # Parse datetime string
        birth_dt = datetime.fromisoformat(birth_data.datetime_str)
        
        # Convert to UTC if timezone is provided
        if birth_data.timezone != "UTC":
            try:
                local_tz = ZoneInfo(birth_data.timezone)
                birth_dt = birth_dt.replace(tzinfo=local_tz)
                birth_dt = birth_dt.astimezone(ZoneInfo("UTC"))
                birth_dt = birth_dt.replace(tzinfo=None)  # Remove tzinfo for calculation
            except Exception as e:
                raise HTTPException(
                    status_code=400, 
                    detail=f"Invalid timezone: {birth_data.timezone}"
                )
        
        # Calculate chart
        chart_data = calculate_natal_chart(
            birth_datetime=birth_dt,
            latitude=birth_data.latitude,
            longitude=birth_data.longitude
        )
        
        # Build response
        planets = [
            PlanetPosition(
                name=p["name"],
                longitude=p["longitude"],
                latitude=p["latitude"],
                distance=p["distance"],
                speed=p["speed"],
                sign=p["sign"],
                sign_degree=p["sign_degree"],
                house=p["house"],
                house_degree=p["house_degree"],
                retrograde=p["retrograde"]
            )
            for p in chart_data["planets"]
        ]
        
        return NatalChartResponse(
            birth_datetime=birth_data.datetime_str,
            latitude=birth_data.latitude,
            longitude=birth_data.longitude,
            timezone=birth_data.timezone,
            ascendant=chart_data["ascendant"],
            ascendant_sign=chart_data["ascendant_sign"],
            planets=planets,
            house_cusps=chart_data["house_cusps"]
        )
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Error calculating chart: {str(e)}"
        )
