"""
Pydantic models for request/response validation.
Implements H2 (Input Validation) rule.
"""
from datetime import datetime
from typing import Optional
from pydantic import BaseModel, Field, field_validator


class BirthDataRequest(BaseModel):
    """
    Request model for birth data input.
    All fields are validated for proper format and ranges.
    """
    datetime_str: str = Field(
        ...,
        alias="datetime",
        description="Birth date and time in ISO format (YYYY-MM-DDTHH:MM:SS)",
        examples=["1990-01-15T14:30:00"]
    )
    latitude: float = Field(
        ...,
        ge=-90.0,
        le=90.0,
        description="Birth location latitude (-90 to 90)"
    )
    longitude: float = Field(
        ...,
        ge=-180.0,
        le=180.0,
        description="Birth location longitude (-180 to 180)"
    )
    timezone: str = Field(
        default="UTC",
        description="Timezone name (e.g., 'America/New_York', 'UTC')"
    )

    @field_validator('datetime_str')
    @classmethod
    def validate_datetime(cls, v: str) -> str:
        """Validate datetime string is in proper ISO format."""
        try:
            datetime.fromisoformat(v)
        except ValueError:
            raise ValueError("datetime must be in ISO format: YYYY-MM-DDTHH:MM:SS")
        return v


class PlanetPosition(BaseModel):
    """
    Model for a single planet's position data.
    """
    name: str = Field(..., description="Planet name")
    longitude: float = Field(..., description="Ecliptic longitude (0-360 degrees)")
    latitude: float = Field(..., description="Ecliptic latitude")
    distance: float = Field(..., description="Distance from Earth in AU")
    speed: float = Field(..., description="Daily motion in degrees")
    sign: str = Field(..., description="Zodiac sign")
    sign_degree: float = Field(..., description="Degree within the sign (0-30)")
    house: int = Field(..., ge=1, le=12, description="House placement (1-12)")
    house_degree: float = Field(..., description="Degree within the house (0-30)")
    retrograde: bool = Field(..., description="Is the planet retrograde")


class NatalChartResponse(BaseModel):
    """
    Response model for natal chart calculation.
    """
    birth_datetime: str = Field(..., description="Input birth datetime")
    latitude: float = Field(..., description="Input latitude")
    longitude: float = Field(..., description="Input longitude")
    timezone: str = Field(..., description="Input timezone")
    ascendant: float = Field(..., description="Ascendant degree")
    ascendant_sign: str = Field(..., description="Ascendant zodiac sign")
    planets: list[PlanetPosition] = Field(..., description="List of planet positions")
    house_cusps: list[float] = Field(..., description="Whole sign house cusp degrees")


class HealthResponse(BaseModel):
    """
    Response model for health check endpoint.
    """
    status: str = Field(..., description="Service status")
    version: str = Field(..., description="API version")
    ephemeris_available: bool = Field(..., description="Swiss Ephemeris availability")
