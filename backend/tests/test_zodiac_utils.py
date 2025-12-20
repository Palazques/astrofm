"""
Unit tests for zodiac utilities module.

Tests zodiac period detection, element mapping, and audio profiles.

H3: Unit Test Creation - Tests for new zodiac_utils module.
"""
import pytest
from datetime import date, datetime
from services.zodiac_utils import (
    get_zodiac_for_date,
    get_current_zodiac,
    get_element_audio_profile,
    get_element_description,
    get_next_zodiac_change_date,
    get_cache_key_for_month,
    ZODIAC_PERIODS,
    ZODIAC_ELEMENTS,
    ELEMENT_AUDIO_PROFILES,
)


class TestGetZodiacForDate:
    """Tests for get_zodiac_for_date function."""
    
    def test_aries_start(self):
        """Test Aries at season start (March 21)."""
        assert get_zodiac_for_date(date(2024, 3, 21)) == "Aries"
    
    def test_aries_end(self):
        """Test Aries at season end (April 19)."""
        assert get_zodiac_for_date(date(2024, 4, 19)) == "Aries"
    
    def test_taurus(self):
        """Test Taurus in middle of season."""
        assert get_zodiac_for_date(date(2024, 5, 1)) == "Taurus"
    
    def test_gemini(self):
        """Test Gemini."""
        assert get_zodiac_for_date(date(2024, 6, 10)) == "Gemini"
    
    def test_cancer(self):
        """Test Cancer."""
        assert get_zodiac_for_date(date(2024, 7, 4)) == "Cancer"
    
    def test_leo(self):
        """Test Leo."""
        assert get_zodiac_for_date(date(2024, 8, 15)) == "Leo"
    
    def test_virgo(self):
        """Test Virgo."""
        assert get_zodiac_for_date(date(2024, 9, 10)) == "Virgo"
    
    def test_libra(self):
        """Test Libra."""
        assert get_zodiac_for_date(date(2024, 10, 1)) == "Libra"
    
    def test_scorpio(self):
        """Test Scorpio."""
        assert get_zodiac_for_date(date(2024, 11, 10)) == "Scorpio"
    
    def test_sagittarius_current(self):
        """Test Sagittarius (current sign as of Dec 20)."""
        assert get_zodiac_for_date(date(2024, 12, 20)) == "Sagittarius"
    
    def test_sagittarius_start(self):
        """Test Sagittarius at season start (Nov 22)."""
        assert get_zodiac_for_date(date(2024, 11, 22)) == "Sagittarius"
    
    def test_sagittarius_end(self):
        """Test Sagittarius at season end (Dec 21)."""
        assert get_zodiac_for_date(date(2024, 12, 21)) == "Sagittarius"
    
    def test_capricorn_december(self):
        """Test Capricorn in December (crosses year boundary)."""
        assert get_zodiac_for_date(date(2024, 12, 25)) == "Capricorn"
    
    def test_capricorn_january(self):
        """Test Capricorn in January."""
        assert get_zodiac_for_date(date(2025, 1, 10)) == "Capricorn"
    
    def test_aquarius(self):
        """Test Aquarius."""
        assert get_zodiac_for_date(date(2024, 2, 5)) == "Aquarius"
    
    def test_pisces(self):
        """Test Pisces."""
        assert get_zodiac_for_date(date(2024, 3, 10)) == "Pisces"


class TestGetCurrentZodiac:
    """Tests for get_current_zodiac function."""
    
    def test_returns_tuple(self):
        """Test that function returns a 4-tuple."""
        result = get_current_zodiac()
        assert isinstance(result, tuple)
        assert len(result) == 4
    
    def test_returns_valid_sign(self):
        """Test that returned sign is in known list."""
        sign, element, date_range, symbol = get_current_zodiac()
        assert sign in ZODIAC_PERIODS.keys()
    
    def test_returns_valid_element(self):
        """Test that returned element is valid."""
        sign, element, date_range, symbol = get_current_zodiac()
        assert element in ["Fire", "Earth", "Air", "Water"]
    
    def test_element_matches_sign(self):
        """Test that element matches the sign."""
        sign, element, date_range, symbol = get_current_zodiac()
        assert ZODIAC_ELEMENTS[sign] == element
    
    def test_date_range_format(self):
        """Test date range has expected format."""
        sign, element, date_range, symbol = get_current_zodiac()
        # Should be like "Nov 22 - Dec 21"
        assert " - " in date_range
        parts = date_range.split(" - ")
        assert len(parts) == 2


class TestElementAudioProfiles:
    """Tests for element audio profile mapping."""
    
    def test_fire_profile(self):
        """Test Fire element audio profile."""
        profile = get_element_audio_profile("Fire")
        assert profile["energy"][0] >= 0.7  # High minimum energy
        assert profile["tempo"][1] >= 140  # High max tempo
    
    def test_earth_profile(self):
        """Test Earth element audio profile."""
        profile = get_element_audio_profile("Earth")
        assert profile["energy"][1] <= 0.7  # Lower max energy
        assert profile["tempo"][0] >= 70  # Moderate min tempo
    
    def test_air_profile(self):
        """Test Air element audio profile."""
        profile = get_element_audio_profile("Air")
        assert "energy" in profile
        assert "valence" in profile
        assert "tempo" in profile
    
    def test_water_profile(self):
        """Test Water element audio profile."""
        profile = get_element_audio_profile("Water")
        assert profile["energy"][0] <= 0.3  # Low minimum energy
        assert profile["valence"][0] <= 0.4  # Can be melancholic
    
    def test_unknown_element_fallback(self):
        """Test unknown element falls back to Fire."""
        profile = get_element_audio_profile("Unknown")
        assert profile == ELEMENT_AUDIO_PROFILES["Fire"]


class TestElementDescriptions:
    """Tests for element description mapping."""
    
    def test_fire_description(self):
        """Test Fire element description."""
        desc = get_element_description("Fire")
        assert "mood" in desc
        assert "sound" in desc
        assert "advice_tone" in desc
    
    def test_all_elements_have_descriptions(self):
        """Test all elements have descriptions."""
        for element in ["Fire", "Earth", "Air", "Water"]:
            desc = get_element_description(element)
            assert len(desc) == 3
            assert all(isinstance(v, str) for v in desc.values())


class TestZodiacCaching:
    """Tests for zodiac caching utilities."""
    
    def test_cache_key_format(self):
        """Test cache key includes year and sign."""
        key = get_cache_key_for_month()
        assert key.startswith("zodiac_")
        assert str(date.today().year) in key
    
    def test_next_change_date_is_future(self):
        """Test next zodiac change is in the future."""
        next_change = get_next_zodiac_change_date()
        assert next_change >= date.today()
    
    def test_next_change_date_within_month(self):
        """Test next zodiac change is within ~31 days."""
        today = date.today()
        next_change = get_next_zodiac_change_date()
        delta = (next_change - today).days
        assert 0 <= delta <= 31
