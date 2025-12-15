"""
Unit tests for the sonification service.
Tests frequency mapping, intensity calculation, and chart sonification.
"""
import math
import pytest
from datetime import datetime

from services.sonification import (
    calculate_intensity,
    calculate_pan_position,
    calculate_planet_sound,
    calculate_chart_sonification,
    PLANET_FREQUENCIES,
    HOUSE_TIMBRES,
)
from models.sonification_schemas import PlanetSound, ChartSonification


class TestIntensityCalculation:
    """Tests for the intensity/distinctness calculation."""
    
    def test_intensity_at_cusp_start(self):
        """Intensity should be near 0 at 0 degrees (cusp)."""
        intensity = calculate_intensity(0.0)
        assert intensity == pytest.approx(0.0, abs=0.01)
    
    def test_intensity_at_mid_house(self):
        """Intensity should be maximum (1.0) at 15 degrees."""
        intensity = calculate_intensity(15.0)
        assert intensity == pytest.approx(1.0, abs=0.01)
    
    def test_intensity_at_cusp_end(self):
        """Intensity should be near 0 at 30 degrees (cusp)."""
        intensity = calculate_intensity(30.0)
        assert intensity == pytest.approx(0.0, abs=0.01)
    
    def test_intensity_smooth_curve(self):
        """Intensity should follow a smooth bell curve."""
        # At 7.5 degrees, should be sin(pi/4) ≈ 0.707
        intensity = calculate_intensity(7.5)
        expected = math.sin(math.pi / 4)
        assert intensity == pytest.approx(expected, abs=0.01)
    
    def test_intensity_symmetric(self):
        """Intensity should be symmetric around midpoint."""
        intensity_5 = calculate_intensity(5.0)
        intensity_25 = calculate_intensity(25.0)
        assert intensity_5 == pytest.approx(intensity_25, abs=0.01)


class TestPlanetFrequencies:
    """Tests for planet-to-frequency mapping."""
    
    def test_sun_frequency(self):
        """Sun should have frequency 126.22 Hz."""
        assert PLANET_FREQUENCIES["Sun"] == pytest.approx(126.22, abs=0.01)
    
    def test_moon_frequency(self):
        """Moon should have frequency 210.42 Hz."""
        assert PLANET_FREQUENCIES["Moon"] == pytest.approx(210.42, abs=0.01)
    
    def test_all_planets_have_frequencies(self):
        """All major planets should have assigned frequencies."""
        expected_planets = [
            "Sun", "Moon", "Mercury", "Venus", "Mars",
            "Jupiter", "Saturn", "Uranus", "Neptune", "Pluto"
        ]
        for planet in expected_planets:
            assert planet in PLANET_FREQUENCIES
            assert PLANET_FREQUENCIES[planet] > 0


class TestHouseTimbres:
    """Tests for house-to-timbre mapping."""
    
    def test_all_houses_have_timbres(self):
        """All 12 houses should have timbre definitions."""
        for house in range(1, 13):
            assert house in HOUSE_TIMBRES
    
    def test_angular_houses_have_action_quality(self):
        """Angular houses (1, 4, 7, 10) should have Angular quality."""
        angular_houses = [1, 4, 7, 10]
        for house in angular_houses:
            assert HOUSE_TIMBRES[house].quality == "Angular"
    
    def test_succedent_houses_have_security_quality(self):
        """Succedent houses (2, 5, 8, 11) should have Succedent quality."""
        succedent_houses = [2, 5, 8, 11]
        for house in succedent_houses:
            assert HOUSE_TIMBRES[house].quality == "Succedent"
    
    def test_cadent_houses_have_learning_quality(self):
        """Cadent houses (3, 6, 9, 12) should have Cadent quality."""
        cadent_houses = [3, 6, 9, 12]
        for house in cadent_houses:
            assert HOUSE_TIMBRES[house].quality == "Cadent"


class TestPanPosition:
    """Tests for stereo pan calculation."""
    
    def test_early_houses_lean_left(self):
        """Houses 1-3 should generally pan left (negative)."""
        pan = calculate_pan_position("Sun", 1)
        assert pan <= 0
    
    def test_late_houses_lean_right(self):
        """Houses 10-12 should generally pan right (positive)."""
        pan = calculate_pan_position("Sun", 12)
        assert pan >= 0
    
    def test_pan_in_valid_range(self):
        """Pan should always be between -1 and 1."""
        for house in range(1, 13):
            pan = calculate_pan_position("Sun", house)
            assert -1 <= pan <= 1


class TestPlanetSound:
    """Tests for individual planet sound calculation."""
    
    def test_planet_sound_has_correct_frequency(self):
        """Planet sound should use the cosmic octave frequency."""
        planet_position = {
            "name": "Sun",
            "house": 1,
            "house_degree": 15.0,
            "sign": "Aries"
        }
        sound = calculate_planet_sound(planet_position)
        assert sound.frequency == PLANET_FREQUENCIES["Sun"]
    
    def test_planet_sound_uses_house_timbre(self):
        """Planet sound should use filter from its house."""
        planet_position = {
            "name": "Moon",
            "house": 4,
            "house_degree": 10.0,
            "sign": "Cancer"
        }
        sound = calculate_planet_sound(planet_position)
        assert sound.filter_type == HOUSE_TIMBRES[4].filter_type
    
    def test_planet_sound_intensity_varies_with_position(self):
        """Intensity should vary based on house degree."""
        # At mid-house (15 degrees)
        planet_mid = {
            "name": "Mars",
            "house": 5,
            "house_degree": 15.0,
            "sign": "Leo"
        }
        sound_mid = calculate_planet_sound(planet_mid)
        
        # At cusp (0 degrees)
        planet_cusp = {
            "name": "Mars",
            "house": 5,
            "house_degree": 0.0,
            "sign": "Leo"
        }
        sound_cusp = calculate_planet_sound(planet_cusp)
        
        assert sound_mid.intensity > sound_cusp.intensity


class TestChartSonification:
    """Tests for complete chart sonification."""
    
    def test_chart_sonification_includes_all_planets(self):
        """Sonification should include sounds for all planets in chart."""
        mock_chart = {
            "ascendant_sign": "Aries",
            "planets": [
                {"name": "Sun", "house": 1, "house_degree": 15.0, "sign": "Aries"},
                {"name": "Moon", "house": 4, "house_degree": 10.0, "sign": "Cancer"},
                {"name": "Mercury", "house": 2, "house_degree": 5.0, "sign": "Taurus"},
            ]
        }
        sonification = calculate_chart_sonification(mock_chart)
        
        assert len(sonification.planets) == 3
        planet_names = [p.planet for p in sonification.planets]
        assert "Sun" in planet_names
        assert "Moon" in planet_names
        assert "Mercury" in planet_names
    
    def test_chart_sonification_has_dominant_frequency(self):
        """Sonification should identify the dominant frequency."""
        mock_chart = {
            "ascendant_sign": "Aries",
            "planets": [
                {"name": "Sun", "house": 1, "house_degree": 15.0, "sign": "Aries"},
                {"name": "Moon", "house": 4, "house_degree": 1.0, "sign": "Cancer"},
            ]
        }
        sonification = calculate_chart_sonification(mock_chart)
        
        # Sun at 15 degrees has max intensity, should be dominant
        assert sonification.dominant_frequency == PLANET_FREQUENCIES["Sun"]
    
    def test_chart_sonification_has_valid_duration(self):
        """Sonification should have a reasonable duration."""
        mock_chart = {
            "ascendant_sign": "Leo",
            "planets": [
                {"name": "Sun", "house": 5, "house_degree": 12.0, "sign": "Leo"},
            ]
        }
        sonification = calculate_chart_sonification(mock_chart)
        
        assert sonification.total_duration >= 10.0
        assert sonification.total_duration <= 60.0
