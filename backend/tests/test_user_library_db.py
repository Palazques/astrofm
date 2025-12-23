"""
Unit tests for User Library Database Service.

Tests for deduplication, insertion, feature updates, and queries.

H3: Unit Test Creation - All public functions must have tests.
C2: Regression Prevention - Tests must pass before committing.
"""
import pytest
import os
import tempfile
from pathlib import Path
from unittest.mock import patch

# Temporarily set DB path for testing before imports
TEST_DB_PATH = Path(tempfile.gettempdir()) / "test_user_library.db"


@pytest.fixture(autouse=True)
def clean_test_db():
    """Clean up test database before and after each test."""
    if TEST_DB_PATH.exists():
        TEST_DB_PATH.unlink()
    
    # Patch the DB_PATH before importing
    with patch('services.user_library_db.DB_PATH', TEST_DB_PATH):
        from services import user_library_db
        # Re-initialize with test path
        user_library_db.DB_PATH = TEST_DB_PATH
        user_library_db.init_database()
        yield user_library_db
    
    if TEST_DB_PATH.exists():
        TEST_DB_PATH.unlink()


@pytest.fixture
def sample_track():
    """Create a sample UserLibraryTrack for testing."""
    from models.user_library_models import UserLibraryTrack
    
    return UserLibraryTrack(
        canonical_name="test song",
        canonical_artist="test artist",
        display_name="Test Song",
        display_artist="Test Artist",
        provider_ids={"spotify": "abc123"},
        energy=0.7,
        valence=0.6,
        tempo=120.0,
        danceability=0.8,
        features_status="complete",
    )


class TestUserLibraryModels:
    """Tests for UserLibraryTrack model."""
    
    def test_canonicalize_basic(self):
        """Test basic canonicalization."""
        from models.user_library_models import UserLibraryTrack
        
        assert UserLibraryTrack.canonicalize("Test Song") == "test song"
        assert UserLibraryTrack.canonicalize("  HELLO  ") == "hello"
    
    def test_canonicalize_removes_remaster_suffix(self):
        """Test canonicalization removes remaster suffixes."""
        from models.user_library_models import UserLibraryTrack
        
        assert UserLibraryTrack.canonicalize("Song (Remastered 2020)") == "song"
        assert UserLibraryTrack.canonicalize("Song (2011 Remaster)") == "song"
    
    def test_canonicalize_removes_feat_suffix(self):
        """Test canonicalization removes featuring suffixes."""
        from models.user_library_models import UserLibraryTrack
        
        assert UserLibraryTrack.canonicalize("Song (feat. Artist)") == "song"
        assert UserLibraryTrack.canonicalize("Song (ft. Artist)") == "song"
    
    def test_has_features_property(self, sample_track):
        """Test has_features property."""
        assert sample_track.has_features is True
        
        sample_track.features_status = "pending"
        assert sample_track.has_features is False


class TestDatabaseOperations:
    """Tests for database CRUD operations."""
    
    def test_insert_track(self, clean_test_db, sample_track):
        """Test inserting a track."""
        track_id = clean_test_db.insert_track(sample_track)
        assert track_id > 0
    
    def test_find_by_provider_id(self, clean_test_db, sample_track):
        """Test finding track by provider ID."""
        clean_test_db.insert_track(sample_track)
        
        found = clean_test_db.find_by_provider_id("spotify", "abc123")
        assert found is not None
        assert found.display_name == "Test Song"
    
    def test_find_by_provider_id_not_found(self, clean_test_db):
        """Test finding non-existent provider ID returns None."""
        found = clean_test_db.find_by_provider_id("spotify", "nonexistent")
        assert found is None
    
    def test_find_by_name_artist_exact(self, clean_test_db, sample_track):
        """Test finding track by exact name+artist match."""
        clean_test_db.insert_track(sample_track)
        
        found = clean_test_db.find_by_name_artist("Test Song", "Test Artist")
        assert found is not None
        assert found.provider_ids.get("spotify") == "abc123"
    
    def test_find_by_name_artist_case_insensitive(self, clean_test_db, sample_track):
        """Test name+artist matching is case-insensitive."""
        clean_test_db.insert_track(sample_track)
        
        found = clean_test_db.find_by_name_artist("TEST SONG", "TEST ARTIST")
        assert found is not None
    
    def test_update_provider_id(self, clean_test_db, sample_track):
        """Test adding a new provider ID to existing track."""
        track_id = clean_test_db.insert_track(sample_track)
        
        clean_test_db.update_provider_id(track_id, "apple_music", "xyz789")
        
        found = clean_test_db.find_by_provider_id("apple_music", "xyz789")
        assert found is not None
        assert found.provider_ids.get("spotify") == "abc123"
        assert found.provider_ids.get("apple_music") == "xyz789"
    
    def test_update_features(self, clean_test_db, sample_track):
        """Test updating audio features."""
        sample_track.features_status = "pending"
        sample_track.energy = None
        track_id = clean_test_db.insert_track(sample_track)
        
        clean_test_db.update_features(track_id, {
            "energy": 0.8,
            "valence": 0.5,
            "tempo": 128.0,
            "danceability": 0.7,
        })
        
        found = clean_test_db.find_by_provider_id("spotify", "abc123")
        assert found.features_status == "complete"
        assert found.energy == 0.8
        assert found.element is not None  # Should be derived
    
    def test_get_tracks_pending_features(self, clean_test_db, sample_track):
        """Test querying pending tracks."""
        sample_track.features_status = "pending"
        sample_track.energy = None
        clean_test_db.insert_track(sample_track)
        
        pending = clean_test_db.get_tracks_pending_features(limit=10)
        assert len(pending) == 1
        assert pending[0].features_status == "pending"
    
    def test_get_tracks_with_features(self, clean_test_db, sample_track):
        """Test querying tracks with complete features."""
        clean_test_db.insert_track(sample_track)
        
        complete = clean_test_db.get_tracks_with_features(limit=10)
        assert len(complete) == 1
        assert complete[0].features_status == "complete"
    
    def test_get_stats(self, clean_test_db, sample_track):
        """Test getting library statistics."""
        clean_test_db.insert_track(sample_track)
        
        stats = clean_test_db.get_stats()
        assert stats["total_tracks"] == 1
        assert stats["complete_features"] == 1
        assert stats["pending_features"] == 0


class TestElementDerivation:
    """Tests for element derivation from audio features."""
    
    def test_derive_element_fire_high_energy(self, clean_test_db):
        """High energy tracks should be Fire."""
        element = clean_test_db._derive_element({"energy": 0.8, "tempo": 120})
        assert element == "Fire"
    
    def test_derive_element_fire_high_tempo(self, clean_test_db):
        """High tempo tracks should be Fire."""
        element = clean_test_db._derive_element({"energy": 0.5, "tempo": 140})
        assert element == "Fire"
    
    def test_derive_element_earth(self, clean_test_db):
        """Low energy + high acousticness should be Earth."""
        element = clean_test_db._derive_element({
            "energy": 0.3, 
            "acousticness": 0.7, 
            "tempo": 100
        })
        assert element == "Earth"
    
    def test_derive_element_air(self, clean_test_db):
        """Danceable + moderate energy should be Air."""
        element = clean_test_db._derive_element({
            "energy": 0.5, 
            "danceability": 0.7, 
            "tempo": 110,
            "valence": 0.5,
            "acousticness": 0.3,
        })
        assert element == "Air"
    
    def test_derive_element_water(self, clean_test_db):
        """Extreme valence should be Water."""
        element = clean_test_db._derive_element({
            "energy": 0.5, 
            "valence": 0.2,  # Low valence = emotional
            "tempo": 100,
            "acousticness": 0.3,
            "danceability": 0.4,
        })
        assert element == "Water"
