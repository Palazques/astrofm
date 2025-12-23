"""
Unit tests for Spotify session persistence.

Verifies that sessions are correctly saved to and restored from SQLite.
"""
import pytest
from datetime import datetime, timedelta, timezone
from pathlib import Path
import os

# Use a test database file
TEST_DB_PATH = Path(__file__).parent.parent / "data" / "test_spotify_sessions.db"


@pytest.fixture(autouse=True)
def setup_and_teardown():
    """Set up test database and clean up after tests."""
    # Import after potential patching
    import services.spotify_sessions_db as db_module
    
    # Point to test database
    original_path = db_module.DB_PATH
    db_module.DB_PATH = TEST_DB_PATH
    
    # Re-initialize with test path
    db_module.init_database()
    
    yield
    
    # Restore original path
    db_module.DB_PATH = original_path
    
    # Clean up test database
    if TEST_DB_PATH.exists():
        os.remove(TEST_DB_PATH)


class TestSpotifySessionsDB:
    """Test cases for spotify_sessions_db.py."""
    
    def test_init_database_creates_table(self):
        """Test that init_database creates the sessions table."""
        import sqlite3
        
        conn = sqlite3.connect(str(TEST_DB_PATH))
        cursor = conn.cursor()
        
        # Check table exists
        cursor.execute("""
            SELECT name FROM sqlite_master 
            WHERE type='table' AND name='sessions'
        """)
        result = cursor.fetchone()
        conn.close()
        
        assert result is not None
        assert result[0] == "sessions"
    
    def test_save_and_get_session(self):
        """Test saving and retrieving a session."""
        from services.spotify_sessions_db import (
            save_session, get_session, StoredSpotifySession
        )
        
        session = StoredSpotifySession(
            session_id="test_session_123",
            access_token="access_abc",
            refresh_token="refresh_xyz",
            expires_at=datetime.now(timezone.utc) + timedelta(hours=1),
            user_id="user_456",
            display_name="Test User",
            email="test@example.com",
            product="premium",
        )
        
        save_session(session)
        
        retrieved = get_session("test_session_123")
        
        assert retrieved is not None
        assert retrieved.session_id == "test_session_123"
        assert retrieved.access_token == "access_abc"
        assert retrieved.refresh_token == "refresh_xyz"
        assert retrieved.user_id == "user_456"
        assert retrieved.display_name == "Test User"
        assert retrieved.product == "premium"
    
    def test_update_existing_session(self):
        """Test that saving again updates instead of duplicating."""
        from services.spotify_sessions_db import (
            save_session, get_session, get_all_sessions, StoredSpotifySession
        )
        
        session = StoredSpotifySession(
            session_id="update_test_session",
            access_token="old_token",
            refresh_token="old_refresh",
            expires_at=datetime.now(timezone.utc) + timedelta(hours=1),
            user_id="user_789",
            display_name="Update User",
            email=None,
            product=None,
        )
        
        save_session(session)
        
        # Update with new tokens
        session.access_token = "new_token"
        session.refresh_token = "new_refresh"
        save_session(session)
        
        # Should still only have one session
        all_sessions = get_all_sessions()
        matching = [s for s in all_sessions if s.session_id == "update_test_session"]
        assert len(matching) == 1
        
        # Should have updated values
        retrieved = get_session("update_test_session")
        assert retrieved.access_token == "new_token"
        assert retrieved.refresh_token == "new_refresh"
    
    def test_update_tokens(self):
        """Test updating tokens after refresh."""
        from services.spotify_sessions_db import (
            save_session, get_session, update_tokens, StoredSpotifySession
        )
        
        session = StoredSpotifySession(
            session_id="token_update_session",
            access_token="initial_access",
            refresh_token="initial_refresh",
            expires_at=datetime.now(timezone.utc) + timedelta(hours=1),
            user_id="user_token_test",
            display_name="Token Test",
            email=None,
            product=None,
        )
        
        save_session(session)
        
        # Update tokens
        new_expires = datetime.now(timezone.utc) + timedelta(hours=2)
        update_tokens(
            "token_update_session",
            "refreshed_access",
            "refreshed_refresh",
            new_expires
        )
        
        retrieved = get_session("token_update_session")
        assert retrieved.access_token == "refreshed_access"
        assert retrieved.refresh_token == "refreshed_refresh"
    
    def test_delete_session(self):
        """Test deleting a session."""
        from services.spotify_sessions_db import (
            save_session, get_session, delete_session, StoredSpotifySession
        )
        
        session = StoredSpotifySession(
            session_id="delete_me_session",
            access_token="doomed_token",
            refresh_token="doomed_refresh",
            expires_at=datetime.now(timezone.utc) + timedelta(hours=1),
            user_id="doomed_user",
            display_name="Doomed",
            email=None,
            product=None,
        )
        
        save_session(session)
        
        # Verify it exists
        assert get_session("delete_me_session") is not None
        
        # Delete it
        delete_session("delete_me_session")
        
        # Verify it's gone
        assert get_session("delete_me_session") is None
    
    def test_get_all_sessions(self):
        """Test retrieving all sessions."""
        from services.spotify_sessions_db import (
            save_session, get_all_sessions, StoredSpotifySession
        )
        
        # Save multiple sessions
        for i in range(3):
            session = StoredSpotifySession(
                session_id=f"multi_session_{i}",
                access_token=f"access_{i}",
                refresh_token=f"refresh_{i}",
                expires_at=datetime.now(timezone.utc) + timedelta(hours=1),
                user_id=f"user_{i}",
                display_name=f"User {i}",
                email=None,
                product=None,
            )
            save_session(session)
        
        all_sessions = get_all_sessions()
        
        # Should have at least our 3 sessions
        multi_sessions = [s for s in all_sessions if s.session_id.startswith("multi_session_")]
        assert len(multi_sessions) == 3
