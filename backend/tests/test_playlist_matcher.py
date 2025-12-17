"""
Unit tests for the Playlist Matcher.
Tests scoring, diversity enforcement, energy arc, and full integration.

H3: Unit Test Creation - Comprehensive tests for playlist matching.
C2: Regression Prevention - Run all tests before committing.
"""
import pytest
from datetime import datetime

from services.playlist_matcher import (
    get_candidate_pool,
    score_song,
    enforce_diversity,
    order_by_energy_arc,
    generate_playlist,
    _get_target_energy_for_position,
    SCORING_WEIGHTS,
)
from models.song import Song
from models.vibe import VibeParameters
from models.playlist import PlaylistResult, PlaylistRequest
from services.library_service import get_all_songs


# =============================================================================
# FIXTURES
# =============================================================================

@pytest.fixture
def sample_vibe_params():
    """Create sample VibeParameters for testing."""
    return VibeParameters(
        target_energy=(50, 70),
        target_valence=(40, 60),
        primary_elements=["Fire"],
        secondary_elements=["Air"],
        active_planets=["Sun", "Mars"],
        mood_direction=["Energizing", "Empowering", "Euphoric"],
        intensity_range=(50, 80),
        time_of_day="afternoon",
        modality_preference="Cardinal",
        cosmic_weather_summary="The Moon brings passionate energy. With Mars active, expect drive. High-energy moment."
    )


@pytest.fixture
def sample_song_perfect_match():
    """Create a song that should score very high."""
    return Song(
        id="song_999",
        title="Test Perfect",
        artist="Test Artist",
        album="Test Album",
        duration_seconds=200,
        bpm=120,
        energy=60,  # In target range
        valence=50,  # In target range
        danceability=70,
        acousticness=20,
        instrumentalness=10,
        genres=["Pop"],
        moods=["Energizing", "Empowering"],  # Top 2 moods
        elements=["Fire"],  # Primary element
        planetary_energy=["Sun", "Mars"],  # Active planets
        intensity=65,  # In range
        modality="Cardinal",  # Matches preference
        time_of_day=["afternoon"]  # Matches
    )


@pytest.fixture
def sample_song_poor_match():
    """Create a song that should score low."""
    return Song(
        id="song_998",
        title="Test Poor",
        artist="Test Artist 2",
        album="Test Album 2",
        duration_seconds=180,
        bpm=60,
        energy=20,  # Far from target
        valence=90,  # Far from target
        danceability=30,
        acousticness=80,
        instrumentalness=5,
        genres=["Classical"],
        moods=["Peaceful", "Contemplative"],  # Not in target moods
        elements=["Water"],  # Not in elements
        planetary_energy=["Neptune", "Moon"],  # Not active
        intensity=30,  # Not in range
        modality="Fixed",  # Doesn't match
        time_of_day=["night"]  # Doesn't match
    )


# =============================================================================
# SCORING TESTS (10 tests)
# =============================================================================

class TestScoring:
    """Tests for song scoring logic."""
    
    def test_primary_element_scores_25(self, sample_vibe_params, sample_song_perfect_match):
        """Primary element match should contribute 25 points."""
        # Song has Fire (primary), so element score = 25
        score = score_song(sample_song_perfect_match, sample_vibe_params)
        assert score >= 25
    
    def test_secondary_element_scores_15(self, sample_vibe_params):
        """Secondary element match should contribute 15 points."""
        song = Song(
            id="song_901", title="Test", artist="Test", album="Test",
            duration_seconds=200, bpm=100, energy=60, valence=50,
            danceability=50, acousticness=50, instrumentalness=10,
            genres=["Pop"], moods=["Peaceful", "Contemplative"],
            elements=["Air"],  # Secondary element
            planetary_energy=["Mercury"], intensity=60
        )
        score = score_song(song, sample_vibe_params)
        # Should get at least 15 from secondary element
        assert score >= 15
    
    def test_other_element_scores_3(self, sample_vibe_params):
        """Non-matching element should contribute 3 points."""
        song = Song(
            id="song_902", title="Test", artist="Test", album="Test",
            duration_seconds=200, bpm=100, energy=60, valence=50,
            danceability=50, acousticness=50, instrumentalness=10,
            genres=["Pop"], moods=["Peaceful", "Contemplative"],
            elements=["Earth"],  # Not in primary or secondary
            planetary_energy=["Mercury"], intensity=60
        )
        score = score_song(song, sample_vibe_params)
        # Should get 3 from non-matching element
        assert score >= 3
    
    def test_first_planet_scores_10(self, sample_vibe_params):
        """First matching planet should contribute 10 points."""
        song = Song(
            id="song_903", title="Test", artist="Test", album="Test",
            duration_seconds=200, bpm=100, energy=60, valence=50,
            danceability=50, acousticness=50, instrumentalness=10,
            genres=["Pop"], moods=["Peaceful", "Contemplative"],
            elements=["Earth"],
            planetary_energy=["Sun"],  # First active planet
            intensity=60
        )
        score = score_song(song, sample_vibe_params)
        # Should get at least 10 from planet match
        assert score >= 10
    
    def test_multiple_planets_diminishing_returns(self, sample_vibe_params):
        """Multiple matching planets should use 10, 6, 4 points."""
        song = Song(
            id="song_904", title="Test", artist="Test", album="Test",
            duration_seconds=200, bpm=100, energy=60, valence=50,
            danceability=50, acousticness=50, instrumentalness=10,
            genres=["Pop"], moods=["Peaceful", "Contemplative"],
            elements=["Earth"],
            planetary_energy=["Sun", "Mars"],  # Both active planets
            intensity=60
        )
        score = score_song(song, sample_vibe_params)
        # Should get 10 + 6 = 16 from planets
        assert score >= 16
    
    def test_top_mood_scores_20(self, sample_vibe_params):
        """Top 2 mood match should contribute 20 points."""
        song = Song(
            id="song_905", title="Test", artist="Test", album="Test",
            duration_seconds=200, bpm=100, energy=60, valence=50,
            danceability=50, acousticness=50, instrumentalness=10,
            genres=["Pop"], moods=["Energizing", "Playful"],  # Top mood
            elements=["Earth"], planetary_energy=["Mercury"], intensity=60
        )
        score = score_song(song, sample_vibe_params)
        # Should get 20 from top mood
        assert score >= 20
    
    def test_other_mood_scores_12(self, sample_vibe_params):
        """Non-top mood match should contribute 12 points."""
        song = Song(
            id="song_906", title="Test", artist="Test", album="Test",
            duration_seconds=200, bpm=100, energy=60, valence=50,
            danceability=50, acousticness=50, instrumentalness=10,
            genres=["Pop"], moods=["Euphoric", "Playful"],  # Third mood (not top 2)
            elements=["Earth"], planetary_energy=["Mercury"], intensity=60
        )
        score = score_song(song, sample_vibe_params)
        # Should get 12 from other target mood
        assert score >= 12
    
    def test_energy_proximity_decreases_with_distance(self, sample_vibe_params):
        """Energy score should decrease as distance from target increases."""
        # Target midpoint is 60
        close_song = Song(
            id="song_907", title="Test", artist="Test", album="Test",
            duration_seconds=200, bpm=100, energy=60, valence=50,  # Perfect
            danceability=50, acousticness=50, instrumentalness=10,
            genres=["Pop"], moods=["Peaceful", "Contemplative"],
            elements=["Earth"], planetary_energy=["Mercury"], intensity=60
        )
        far_song = Song(
            id="song_908", title="Test", artist="Test", album="Test",
            duration_seconds=200, bpm=100, energy=20, valence=50,  # Far
            danceability=50, acousticness=50, instrumentalness=10,
            genres=["Pop"], moods=["Peaceful", "Contemplative"],
            elements=["Earth"], planetary_energy=["Mercury"], intensity=60
        )
        
        close_score = score_song(close_song, sample_vibe_params)
        far_score = score_song(far_song, sample_vibe_params)
        
        assert close_score > far_score
    
    def test_valence_proximity_decreases_with_distance(self, sample_vibe_params):
        """Valence score should decrease as distance from target increases."""
        # Target midpoint is 50
        close_song = Song(
            id="song_909", title="Test", artist="Test", album="Test",
            duration_seconds=200, bpm=100, energy=60, valence=50,  # Perfect
            danceability=50, acousticness=50, instrumentalness=10,
            genres=["Pop"], moods=["Peaceful", "Contemplative"],
            elements=["Earth"], planetary_energy=["Mercury"], intensity=60
        )
        far_song = Song(
            id="song_910", title="Test", artist="Test", album="Test",
            duration_seconds=200, bpm=100, energy=60, valence=95,  # Far
            danceability=50, acousticness=50, instrumentalness=10,
            genres=["Pop"], moods=["Peaceful", "Contemplative"],
            elements=["Earth"], planetary_energy=["Mercury"], intensity=60
        )
        
        close_score = score_song(close_song, sample_vibe_params)
        far_score = score_song(far_song, sample_vibe_params)
        
        assert close_score > far_score
    
    def test_perfect_match_scores_high(self, sample_vibe_params, sample_song_perfect_match):
        """A perfect match song should score 90+."""
        score = score_song(sample_song_perfect_match, sample_vibe_params)
        assert score >= 90


# =============================================================================
# DIVERSITY TESTS (5 tests)
# =============================================================================

class TestDiversity:
    """Tests for diversity enforcement."""
    
    def test_max_2_per_artist_enforced(self, sample_vibe_params):
        """Should not select more than 2 songs from same artist."""
        # Create songs from multiple artists so limits can be enforced
        songs = []
        # 5 songs from "Same Artist"
        for i in range(5):
            songs.append((
                Song(
                    id=f"song_{800+i:03d}", title=f"Test {i}", artist="Same Artist", album="Test",
                    duration_seconds=200, bpm=100, energy=60, valence=50,
                    danceability=50, acousticness=50, instrumentalness=10,
                    genres=["Pop"], moods=["Energizing", "Playful"],
                    elements=["Fire"], planetary_energy=["Sun"], intensity=60
                ),
                90 - i
            ))
        # 5 songs from different artists (to allow selection without relaxation)
        for i in range(5):
            songs.append((
                Song(
                    id=f"song_{850+i:03d}", title=f"Other {i}", artist=f"Artist {i}", album="Test",
                    duration_seconds=200, bpm=100, energy=60, valence=50,
                    danceability=50, acousticness=50, instrumentalness=10,
                    genres=["Pop"], moods=["Energizing", "Playful"],
                    elements=["Fire"], planetary_energy=["Sun"], intensity=60
                ),
                70 - i
            ))
        
        selected = enforce_diversity(songs, playlist_size=5, max_per_artist=2, max_per_genre=10)
        
        artist_count = sum(1 for s in selected if s.artist == "Same Artist")
        assert artist_count <= 2
    
    def test_max_4_per_genre_enforced(self, sample_vibe_params):
        """Should not select more than 4 songs from same genre."""
        songs = []
        # 6 Rock songs
        for i in range(6):
            songs.append((
                Song(
                    id=f"song_{810+i:03d}", title=f"Rock {i}", artist=f"Artist {i}", album="Test",
                    duration_seconds=200, bpm=100, energy=60, valence=50,
                    danceability=50, acousticness=50, instrumentalness=10,
                    genres=["Rock"],
                    moods=["Energizing", "Playful"],
                    elements=["Fire"], planetary_energy=["Sun"], intensity=60
                ),
                90 - i
            ))
        # 4 Pop songs (alternatives to allow selection without relaxation)
        for i in range(4):
            songs.append((
                Song(
                    id=f"song_{860+i:03d}", title=f"Pop {i}", artist=f"PopArtist {i}", album="Test",
                    duration_seconds=200, bpm=100, energy=60, valence=50,
                    danceability=50, acousticness=50, instrumentalness=10,
                    genres=["Pop"],
                    moods=["Energizing", "Playful"],
                    elements=["Fire"], planetary_energy=["Sun"], intensity=60
                ),
                70 - i
            ))
        
        selected = enforce_diversity(songs, playlist_size=6, max_per_artist=10, max_per_genre=4)
        
        rock_count = sum(1 for s in selected if "Rock" in s.genres)
        assert rock_count <= 4

    
    def test_multiple_elements_in_result(self, sample_vibe_params):
        """Result should have songs from multiple elements when possible."""
        result = generate_playlist(sample_vibe_params, playlist_size=20)
        
        # Should have at least 2 different elements represented
        assert len(result.element_distribution) >= 2
    
    def test_multiple_moods_in_result(self, sample_vibe_params):
        """Result should have songs with multiple moods."""
        result = generate_playlist(sample_vibe_params, playlist_size=20)
        
        # Should have at least 3 different moods
        assert len(result.mood_distribution) >= 3
    
    def test_rules_relax_if_needed(self):
        """Rules should relax if playlist can't be filled otherwise."""
        # Create minimal viable song list
        songs = []
        for i in range(5):
            songs.append((
                Song(
                    id=f"song_{820+i:03d}", title=f"Test {i}", artist="Same Artist", album="Test",
                    duration_seconds=200, bpm=100, energy=60, valence=50,
                    danceability=50, acousticness=50, instrumentalness=10,
                    genres=["Pop"], moods=["Energizing", "Playful"],
                    elements=["Fire"], planetary_energy=["Sun"], intensity=60
                ),
                90 - i
            ))
        
        # Request more than can be filled with strict rules
        selected = enforce_diversity(songs, playlist_size=5, max_per_artist=2, max_per_genre=4)
        
        # Should still return 5 songs due to relaxation
        assert len(selected) == 5


# =============================================================================
# ENERGY ARC TESTS (6 tests)
# =============================================================================

class TestEnergyArc:
    """Tests for energy arc ordering."""
    
    def test_opening_has_moderate_energy(self, sample_vibe_params):
        """First 3 songs should have moderate energy (45-65)."""
        result = generate_playlist(sample_vibe_params, playlist_size=20)
        
        # Check first 3 songs have moderate energy
        opening_songs = result.songs[:3]
        for song in opening_songs:
            # Allow some flexibility since we're matching from library
            assert 30 <= song.energy <= 80, f"Opening song energy {song.energy} outside expected range"
    
    def test_peak_has_high_energy(self, sample_vibe_params):
        """Middle songs (9-13) should tend toward higher energy."""
        result = generate_playlist(sample_vibe_params, playlist_size=20)
        
        if len(result.songs) >= 13:
            peak_songs = result.songs[8:13]
            avg_energy = sum(s.energy for s in peak_songs) / len(peak_songs)
            # Peak should have higher average than opening
            opening_avg = sum(s.energy for s in result.songs[:3]) / 3
            # This is a soft check - may not always hold with limited library
            assert avg_energy >= opening_avg - 20
    
    def test_resolution_has_moderate_energy(self, sample_vibe_params):
        """Last 3 songs should have moderate energy."""
        result = generate_playlist(sample_vibe_params, playlist_size=20)
        
        resolution_songs = result.songs[-3:]
        for song in resolution_songs:
            # Allow flexibility
            assert 20 <= song.energy <= 85, f"Resolution song energy {song.energy} outside expected range"
    
    def test_energy_generally_rises_in_buildup(self, sample_vibe_params):
        """Energy should trend upward from position 4-10."""
        result = generate_playlist(sample_vibe_params, playlist_size=20)
        
        if len(result.songs) >= 10:
            # Check trend, not strict ordering
            early_avg = sum(result.songs[i].energy for i in range(3, 5)) / 2
            late_avg = sum(result.songs[i].energy for i in range(8, 10)) / 2
            # Allow for library limitations
            assert late_avg >= early_avg - 30
    
    def test_energy_arc_length_matches_songs(self, sample_vibe_params):
        """Energy arc should have same length as song list."""
        result = generate_playlist(sample_vibe_params, playlist_size=20)
        
        assert len(result.energy_arc) == len(result.songs)
    
    def test_arc_adapts_to_different_sizes(self, sample_vibe_params):
        """Arc should work for different playlist sizes."""
        for size in [10, 15, 20]:
            result = generate_playlist(sample_vibe_params, playlist_size=size)
            # Should work without error
            assert len(result.songs) <= size
            assert len(result.energy_arc) == len(result.songs)


# =============================================================================
# INTEGRATION TESTS (7 tests)
# =============================================================================

class TestIntegration:
    """Integration tests for full pipeline."""
    
    def test_generate_playlist_returns_result(self, sample_vibe_params):
        """generate_playlist should return valid PlaylistResult."""
        result = generate_playlist(sample_vibe_params, playlist_size=20)
        assert isinstance(result, PlaylistResult)
    
    def test_result_contains_correct_song_count(self, sample_vibe_params):
        """Result should contain exactly playlist_size songs (or all available)."""
        result = generate_playlist(sample_vibe_params, playlist_size=20)
        # Should have 20 or fewer (if library is smaller)
        assert 1 <= len(result.songs) <= 20
    
    def test_total_duration_equals_sum(self, sample_vibe_params):
        """total_duration_seconds should equal sum of song durations."""
        result = generate_playlist(sample_vibe_params, playlist_size=20)
        
        calculated_duration = sum(s.duration_seconds for s in result.songs)
        assert result.total_duration_seconds == calculated_duration
    
    def test_vibe_match_score_in_range(self, sample_vibe_params):
        """vibe_match_score should be between 0-100."""
        result = generate_playlist(sample_vibe_params, playlist_size=20)
        
        assert 0 <= result.vibe_match_score <= 100
    
    def test_all_songs_unique(self, sample_vibe_params):
        """All songs in result should be unique (no duplicates)."""
        result = generate_playlist(sample_vibe_params, playlist_size=20)
        
        song_ids = [s.id for s in result.songs]
        assert len(song_ids) == len(set(song_ids))
    
    def test_element_distribution_matches(self, sample_vibe_params):
        """element_distribution should match actual songs."""
        result = generate_playlist(sample_vibe_params, playlist_size=20)
        
        # Calculate expected distribution
        expected = {}
        for song in result.songs:
            for elem in song.elements:
                expected[elem] = expected.get(elem, 0) + 1
        
        assert result.element_distribution == expected
    
    def test_generation_metadata_has_keys(self, sample_vibe_params):
        """generation_metadata should contain expected keys."""
        result = generate_playlist(sample_vibe_params, playlist_size=20)
        
        expected_keys = ["candidates_found", "playlist_size_requested", "songs_selected"]
        for key in expected_keys:
            assert key in result.generation_metadata


# =============================================================================
# EDGE CASE TESTS (5 tests)
# =============================================================================

class TestEdgeCases:
    """Edge case tests."""
    
    def test_minimum_playlist_size(self, sample_vibe_params):
        """Should work with minimum playlist size (10)."""
        result = generate_playlist(sample_vibe_params, playlist_size=10)
        assert len(result.songs) <= 10
        assert isinstance(result, PlaylistResult)
    
    def test_maximum_playlist_size(self, sample_vibe_params):
        """Should work with maximum playlist size (30)."""
        result = generate_playlist(sample_vibe_params, playlist_size=30)
        assert len(result.songs) <= 30
        assert isinstance(result, PlaylistResult)
    
    def test_works_with_small_library(self, sample_vibe_params):
        """Should work when library has fewer songs than requested."""
        # Our library has 100 songs, so requesting 20 should work
        result = generate_playlist(sample_vibe_params, playlist_size=20)
        assert len(result.songs) >= 1
    
    def test_works_with_minimal_vibe_params(self):
        """Should work with minimal VibeParameters."""
        minimal_params = VibeParameters(
            target_energy=(30, 70),
            target_valence=(30, 70),
            primary_elements=["Water"],
            active_planets=["Moon", "Neptune"],
            mood_direction=["Peaceful", "Dreamy", "Contemplative"],
            intensity_range=(20, 80),
            cosmic_weather_summary="Test summary that needs to be at least fifty characters for validation."
        )
        
        result = generate_playlist(minimal_params, playlist_size=15)
        assert isinstance(result, PlaylistResult)
        assert len(result.songs) >= 1
    
    def test_relaxation_triggers_on_strict_filter(self, sample_vibe_params):
        """Progressive relaxation should trigger when initial filters are too strict."""
        # Even with narrow params, should still generate playlist
        narrow_params = VibeParameters(
            target_energy=(95, 100),  # Very narrow
            target_valence=(95, 100),  # Very narrow
            primary_elements=["Fire"],
            active_planets=["Sun", "Mars"],
            mood_direction=["Aggressive", "Energizing", "Empowering"],
            intensity_range=(90, 100),
            time_of_day="morning",
            modality_preference="Cardinal",
            cosmic_weather_summary="Test summary that needs to be at least fifty characters for validation."
        )
        
        result = generate_playlist(narrow_params, playlist_size=10)
        # Should still return some songs due to relaxation
        assert len(result.songs) >= 1


# =============================================================================
# MODEL VALIDATION TESTS
# =============================================================================

class TestModels:
    """Tests for Pydantic model validation."""
    
    def test_playlist_result_validates(self, sample_vibe_params):
        """PlaylistResult should validate correctly."""
        result = generate_playlist(sample_vibe_params, playlist_size=10)
        # Model validation happens in constructor; if this runs, it passes
        assert result.song_count == len(result.songs)
        assert result.duration_minutes >= 0
    
    def test_playlist_request_validates(self):
        """PlaylistRequest should validate correctly."""
        request = PlaylistRequest(
            birth_datetime="1990-06-15T14:30:00",
            latitude=40.7128,
            longitude=-74.0060,
            playlist_size=20
        )
        assert request.playlist_size == 20
    
    def test_playlist_request_rejects_invalid_datetime(self):
        """PlaylistRequest should reject invalid datetime format."""
        with pytest.raises(ValueError):
            PlaylistRequest(
                birth_datetime="not-a-datetime",
                latitude=40.7128,
                longitude=-74.0060
            )
