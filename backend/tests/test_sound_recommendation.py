"""
Unit tests for the sound recommendation service.
Tests recommendation generation, life area filtering, and frequency data.
"""
import pytest
from datetime import datetime, timezone

from services.sound_recommendation import (
    get_sound_recommendations,
    get_recommendations_by_life_area,
)
from models.sound_recommendation_schemas import (
    SoundRecommendation,
    SoundRecommendationsResponse,
    LIFE_AREA_KEYS,
    LIFE_AREA_LABELS,
)


class TestSoundRecommendations:
    """Tests for get_sound_recommendations function."""
    
    # Test birth data
    TEST_BIRTH = datetime(1990, 7, 15, 15, 42)
    TEST_LAT = 34.0522
    TEST_LON = -118.2437
    
    def test_returns_valid_response(self):
        """Should return valid SoundRecommendationsResponse object."""
        result = get_sound_recommendations(
            birth_datetime=self.TEST_BIRTH,
            latitude=self.TEST_LAT,
            longitude=self.TEST_LON
        )
        assert isinstance(result, SoundRecommendationsResponse)
    
    def test_has_required_fields(self):
        """Response should have all required fields."""
        result = get_sound_recommendations(
            birth_datetime=self.TEST_BIRTH,
            latitude=self.TEST_LAT,
            longitude=self.TEST_LON
        )
        assert hasattr(result, 'primary_recommendation')
        assert hasattr(result, 'all_recommendations')
        assert hasattr(result, 'gaps')
        assert hasattr(result, 'resonances')
        assert hasattr(result, 'alignment_score')
    
    def test_recommendations_include_frequencies(self):
        """All recommendations should include valid frequencies."""
        result = get_sound_recommendations(
            birth_datetime=self.TEST_BIRTH,
            latitude=self.TEST_LAT,
            longitude=self.TEST_LON
        )
        for rec in result.all_recommendations:
            assert rec.frequency > 0
            assert rec.frequency < 1000  # Reasonable frequency range
    
    def test_recommendations_include_explanations(self):
        """All recommendations should have explanations."""
        result = get_sound_recommendations(
            birth_datetime=self.TEST_BIRTH,
            latitude=self.TEST_LAT,
            longitude=self.TEST_LON
        )
        for rec in result.all_recommendations:
            assert rec.explanation != ""
            assert len(rec.explanation) > 20  # Not just a placeholder
    
    def test_recommendations_have_valid_life_areas(self):
        """All recommendations should have valid life area keys."""
        result = get_sound_recommendations(
            birth_datetime=self.TEST_BIRTH,
            latitude=self.TEST_LAT,
            longitude=self.TEST_LON
        )
        valid_keys = list(LIFE_AREA_KEYS.values())
        for rec in result.all_recommendations:
            assert rec.life_area_key in valid_keys
    
    def test_gaps_have_gap_status(self):
        """All items in gaps list should have status 'gap'."""
        result = get_sound_recommendations(
            birth_datetime=self.TEST_BIRTH,
            latitude=self.TEST_LAT,
            longitude=self.TEST_LON
        )
        for gap in result.gaps:
            assert gap.status == "gap"
    
    def test_resonances_have_resonance_status(self):
        """All items in resonances list should have status 'resonance'."""
        result = get_sound_recommendations(
            birth_datetime=self.TEST_BIRTH,
            latitude=self.TEST_LAT,
            longitude=self.TEST_LON
        )
        for res in result.resonances:
            assert res.status == "resonance"
    
    def test_alignment_score_in_valid_range(self):
        """Alignment score should be 0-100."""
        result = get_sound_recommendations(
            birth_datetime=self.TEST_BIRTH,
            latitude=self.TEST_LAT,
            longitude=self.TEST_LON
        )
        assert 0 <= result.alignment_score <= 100
    
    def test_primary_recommendation_exists_when_recommendations_exist(self):
        """Primary recommendation should be set when there are any recommendations."""
        result = get_sound_recommendations(
            birth_datetime=self.TEST_BIRTH,
            latitude=self.TEST_LAT,
            longitude=self.TEST_LON
        )
        if result.all_recommendations:
            assert result.primary_recommendation is not None


class TestLifeAreaFiltering:
    """Tests for get_recommendations_by_life_area function."""
    
    TEST_BIRTH = datetime(1990, 7, 15, 15, 42)
    TEST_LAT = 34.0522
    TEST_LON = -118.2437
    
    def test_returns_recommendation_for_valid_life_area(self):
        """Should return a recommendation for valid life area keys."""
        # Test with career_purpose (10th house)
        result = get_recommendations_by_life_area(
            birth_datetime=self.TEST_BIRTH,
            latitude=self.TEST_LAT,
            longitude=self.TEST_LON,
            life_area_key="career_purpose"
        )
        # May return None if no match, but should not error
        if result:
            assert isinstance(result, SoundRecommendation)
    
    def test_recommendation_has_correct_life_area_key(self):
        """Returned recommendation should match requested life area."""
        life_area = "partnerships"
        result = get_recommendations_by_life_area(
            birth_datetime=self.TEST_BIRTH,
            latitude=self.TEST_LAT,
            longitude=self.TEST_LON,
            life_area_key=life_area
        )
        if result:
            assert result.life_area_key == life_area
    
    def test_all_life_areas_return_without_error(self):
        """All defined life area keys should work without errors."""
        for life_area_key in LIFE_AREA_KEYS.values():
            result = get_recommendations_by_life_area(
                birth_datetime=self.TEST_BIRTH,
                latitude=self.TEST_LAT,
                longitude=self.TEST_LON,
                life_area_key=life_area_key
            )
            # Should return either a valid recommendation or None
            assert result is None or isinstance(result, SoundRecommendation)


class TestAspectBlends:
    """Tests for aspect blend frequency data."""
    
    TEST_BIRTH = datetime(1990, 7, 15, 15, 42)
    TEST_LAT = 34.0522
    TEST_LON = -118.2437
    
    def test_recommendations_include_aspect_blends(self):
        """Recommendations should include aspect blend data."""
        result = get_sound_recommendations(
            birth_datetime=self.TEST_BIRTH,
            latitude=self.TEST_LAT,
            longitude=self.TEST_LON
        )
        # At least some recommendations should have aspect blends
        has_blends = any(
            len(rec.aspect_blends) > 0 
            for rec in result.all_recommendations
        )
        assert has_blends
    
    def test_aspect_blends_have_valid_frequencies(self):
        """Aspect blends should have valid frequency values."""
        result = get_sound_recommendations(
            birth_datetime=self.TEST_BIRTH,
            latitude=self.TEST_LAT,
            longitude=self.TEST_LON
        )
        for rec in result.all_recommendations:
            for blend in rec.aspect_blends:
                assert blend.frequency > 0
                assert blend.frequency < 1000
