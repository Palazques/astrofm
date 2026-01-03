"""
Spotify Session Database Service.

Handles persistent storage of Spotify OAuth sessions so they survive
backend restarts. Users won't need to reconnect after server restart.

C3: Least Privilege - Database access isolated to this module.
H1: Isolation Principle - Separate file for session persistence.
S2: Documentation Rule - All functions include clear docstrings.
"""
import logging
import sqlite3
from pathlib import Path
from typing import Optional, Dict, List
from datetime import datetime, timezone
from contextlib import contextmanager
from dataclasses import dataclass

logger = logging.getLogger(__name__)


# Database path (same directory as other data files)
DB_PATH = Path(__file__).parent.parent / "data" / "spotify_sessions.db"


@dataclass
class StoredSpotifySession:
    """Container for a persisted Spotify session."""
    session_id: str
    access_token: str
    refresh_token: str
    expires_at: datetime
    user_id: str
    display_name: Optional[str]
    email: Optional[str]
    product: Optional[str]
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None


@contextmanager
def get_connection():
    """Get a database connection with proper cleanup."""
    conn = sqlite3.connect(str(DB_PATH))
    conn.row_factory = sqlite3.Row
    try:
        yield conn
    finally:
        conn.close()


def init_database() -> None:
    """
    Initialize the Spotify sessions database schema.
    
    Creates the sessions table if it doesn't exist.
    Safe to call multiple times.
    """
    with get_connection() as conn:
        cursor = conn.cursor()
        
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS sessions (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                session_id TEXT UNIQUE NOT NULL,
                access_token TEXT NOT NULL,
                refresh_token TEXT NOT NULL,
                expires_at TEXT NOT NULL,
                user_id TEXT NOT NULL,
                display_name TEXT,
                email TEXT,
                product TEXT,
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
            )
        """)
        
        # Index for fast session lookups
        cursor.execute("""
            CREATE INDEX IF NOT EXISTS idx_session_id 
            ON sessions(session_id)
        """)
        
        conn.commit()
        print(f"[SpotifySessionsDB] Database initialized at {DB_PATH}")


def save_session(session: StoredSpotifySession) -> None:
    """
    Save or update a Spotify session.
    
    Uses INSERT OR REPLACE to handle both new and existing sessions.
    
    Args:
        session: The session data to save
    """
    with get_connection() as conn:
        cursor = conn.cursor()
        
        # Check if session exists
        cursor.execute("SELECT id FROM sessions WHERE session_id = ?", (session.session_id,))
        existing = cursor.fetchone()
        
        expires_at_str = session.expires_at.isoformat() if session.expires_at else None
        
        if existing:
            # Update existing session
            cursor.execute("""
                UPDATE sessions SET
                    access_token = ?,
                    refresh_token = ?,
                    expires_at = ?,
                    user_id = ?,
                    display_name = ?,
                    email = ?,
                    product = ?,
                    updated_at = CURRENT_TIMESTAMP
                WHERE session_id = ?
            """, (
                session.access_token,
                session.refresh_token,
                expires_at_str,
                session.user_id,
                session.display_name,
                session.email,
                session.product,
                session.session_id,
            ))
        else:
            # Insert new session
            cursor.execute("""
                INSERT INTO sessions (
                    session_id, access_token, refresh_token, expires_at,
                    user_id, display_name, email, product
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
            """, (
                session.session_id,
                session.access_token,
                session.refresh_token,
                expires_at_str,
                session.user_id,
                session.display_name,
                session.email,
                session.product,
            ))
        
        conn.commit()
        print(f"[SpotifySessionsDB] Saved session {session.session_id[:8]}... for user {session.display_name}")


def get_session(session_id: str) -> Optional[StoredSpotifySession]:
    """
    Get a stored session by its ID.
    
    Args:
        session_id: The session ID to look up
        
    Returns:
        StoredSpotifySession if found, None otherwise
    """
    with get_connection() as conn:
        cursor = conn.cursor()
        
        cursor.execute("SELECT * FROM sessions WHERE session_id = ?", (session_id,))
        row = cursor.fetchone()
        
        if row:
            return _row_to_session(row)
        return None


def get_all_sessions() -> List[StoredSpotifySession]:
    """
    Get all stored sessions.
    
    Used to restore sessions into memory on service startup.
    
    Returns:
        List of all stored sessions
    """
    with get_connection() as conn:
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM sessions ORDER BY updated_at DESC")
        return [_row_to_session(row) for row in cursor.fetchall()]


def update_tokens(session_id: str, access_token: str, refresh_token: str, expires_at: datetime) -> None:
    """
    Update tokens for an existing session after refresh.
    
    Args:
        session_id: The session ID to update
        access_token: New access token
        refresh_token: New refresh token (may be same as old)
        expires_at: New expiry timestamp
    """
    with get_connection() as conn:
        cursor = conn.cursor()
        
        cursor.execute("""
            UPDATE sessions SET
                access_token = ?,
                refresh_token = ?,
                expires_at = ?,
                updated_at = CURRENT_TIMESTAMP
            WHERE session_id = ?
        """, (access_token, refresh_token, expires_at.isoformat(), session_id))
        
        conn.commit()
        print(f"[SpotifySessionsDB] Updated tokens for session {session_id[:8]}...")


def delete_session(session_id: str) -> None:
    """
    Delete a session (e.g., when refresh fails).
    
    Args:
        session_id: The session ID to delete
    """
    with get_connection() as conn:
        cursor = conn.cursor()
        cursor.execute("DELETE FROM sessions WHERE session_id = ?", (session_id,))
        conn.commit()
        print(f"[SpotifySessionsDB] Deleted session {session_id[:8]}...")


def _row_to_session(row: sqlite3.Row) -> StoredSpotifySession:
    """Convert a database row to a StoredSpotifySession object."""
    expires_at = None
    if row["expires_at"]:
        try:
            expires_at = datetime.fromisoformat(row["expires_at"])
        except ValueError:
            expires_at = datetime.now(timezone.utc)
    
    created_at = None
    if row["created_at"]:
        try:
            created_at = datetime.fromisoformat(row["created_at"])
        except ValueError as e:
            logger.warning(f"Invalid created_at format in session: {e}")
    
    updated_at = None
    if row["updated_at"]:
        try:
            updated_at = datetime.fromisoformat(row["updated_at"])
        except ValueError as e:
            logger.warning(f"Invalid updated_at format in session: {e}")
    
    return StoredSpotifySession(
        session_id=row["session_id"],
        access_token=row["access_token"],
        refresh_token=row["refresh_token"],
        expires_at=expires_at,
        user_id=row["user_id"],
        display_name=row["display_name"],
        email=row["email"],
        product=row["product"],
        created_at=created_at,
        updated_at=updated_at,
    )


# Initialize database on module import
init_database()
