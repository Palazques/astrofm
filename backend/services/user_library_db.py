"""
User Library Database Service for the shared track pool.

Handles SQLite database operations for user-contributed tracks.
Separate from music_dataset.db to avoid corrupting the original 114K dataset.

C3: Least Privilege - Database access isolated to this module.
H1: Isolation Principle - Separate database for user contributions.
S2: Documentation Rule - All functions include clear docstrings.
"""
import sqlite3
import json
from pathlib import Path
from typing import Optional, List, Dict, Tuple
from datetime import datetime
from contextlib import contextmanager

from models.user_library_models import UserLibraryTrack


# Database path (same directory as music_dataset.db)
DB_PATH = Path(__file__).parent.parent / "data" / "user_library.db"


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
    Initialize the user library database schema.
    
    Creates the tracks table if it doesn't exist.
    Safe to call multiple times.
    """
    with get_connection() as conn:
        cursor = conn.cursor()
        
        # Create main tracks table
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS tracks (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                canonical_name TEXT NOT NULL,
                canonical_artist TEXT NOT NULL,
                display_name TEXT NOT NULL,
                display_artist TEXT NOT NULL,
                provider_ids TEXT NOT NULL DEFAULT '{}',
                energy REAL,
                valence REAL,
                tempo REAL,
                danceability REAL,
                acousticness REAL,
                instrumentalness REAL,
                speechiness REAL,
                liveness REAL,
                loudness REAL,
                mode INTEGER,
                key INTEGER,
                element TEXT,
                features_status TEXT NOT NULL DEFAULT 'pending',
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
            )
        """)
        
        # Create indexes for fast lookups
        cursor.execute("""
            CREATE INDEX IF NOT EXISTS idx_canonical 
            ON tracks(canonical_name, canonical_artist)
        """)
        
        cursor.execute("""
            CREATE INDEX IF NOT EXISTS idx_features_status 
            ON tracks(features_status)
        """)
        
        cursor.execute("""
            CREATE INDEX IF NOT EXISTS idx_element 
            ON tracks(element)
        """)
        
        conn.commit()
        print(f"[UserLibraryDB] Database initialized at {DB_PATH}")


def find_by_provider_id(provider: str, provider_id: str) -> Optional[UserLibraryTrack]:
    """
    Find a track by its provider-specific ID.
    
    This is the fast path for deduplication - O(n) scan but very fast
    for expected database sizes (<100K tracks).
    
    Args:
        provider: Provider name (e.g., "spotify")
        provider_id: The provider's track ID
        
    Returns:
        UserLibraryTrack if found, None otherwise
    """
    with get_connection() as conn:
        cursor = conn.cursor()
        
        # Use JSON extraction for provider ID lookup
        # SQLite JSON functions work well for this use case
        cursor.execute("""
            SELECT * FROM tracks 
            WHERE json_extract(provider_ids, ?) = ?
            LIMIT 1
        """, (f'$.{provider}', provider_id))
        
        row = cursor.fetchone()
        return _row_to_track(row) if row else None


def find_by_name_artist(name: str, artist: str, fuzzy_threshold: float = 0.85) -> Optional[UserLibraryTrack]:
    """
    Find a track by fuzzy matching canonical name and artist.
    
    Uses exact match on canonical forms for now. Future: implement
    Levenshtein distance for true fuzzy matching.
    
    Args:
        name: Song name (will be canonicalized)
        artist: Artist name (will be canonicalized)
        fuzzy_threshold: Similarity threshold (currently unused, for future fuzzy)
        
    Returns:
        UserLibraryTrack if found, None otherwise
    """
    canonical_name = UserLibraryTrack.canonicalize(name)
    canonical_artist = UserLibraryTrack.canonicalize(artist)
    
    with get_connection() as conn:
        cursor = conn.cursor()
        
        # Exact match on canonical forms
        cursor.execute("""
            SELECT * FROM tracks 
            WHERE canonical_name = ? AND canonical_artist = ?
            LIMIT 1
        """, (canonical_name, canonical_artist))
        
        row = cursor.fetchone()
        return _row_to_track(row) if row else None


def insert_track(track: UserLibraryTrack) -> int:
    """
    Insert a new track into the database.
    
    Args:
        track: UserLibraryTrack to insert
        
    Returns:
        The new track's ID
    """
    with get_connection() as conn:
        cursor = conn.cursor()
        
        cursor.execute("""
            INSERT INTO tracks (
                canonical_name, canonical_artist, display_name, display_artist,
                provider_ids, energy, valence, tempo, danceability,
                acousticness, instrumentalness, speechiness, liveness,
                loudness, mode, key, element, features_status
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """, (
            track.canonical_name,
            track.canonical_artist,
            track.display_name,
            track.display_artist,
            json.dumps(track.provider_ids),
            track.energy,
            track.valence,
            track.tempo,
            track.danceability,
            track.acousticness,
            track.instrumentalness,
            track.speechiness,
            track.liveness,
            track.loudness,
            track.mode,
            track.key,
            track.element,
            track.features_status,
        ))
        
        conn.commit()
        return cursor.lastrowid


def update_provider_id(track_id: int, provider: str, provider_id: str) -> None:
    """
    Add a provider ID to an existing track.
    
    Used when the same track is found on a different platform.
    
    Args:
        track_id: Database ID of the track
        provider: Provider name (e.g., "apple_music")
        provider_id: The provider's track ID
    """
    with get_connection() as conn:
        cursor = conn.cursor()
        
        # Get current provider_ids
        cursor.execute("SELECT provider_ids FROM tracks WHERE id = ?", (track_id,))
        row = cursor.fetchone()
        
        if row:
            current_ids = json.loads(row["provider_ids"])
            current_ids[provider] = provider_id
            
            cursor.execute("""
                UPDATE tracks 
                SET provider_ids = ?, updated_at = CURRENT_TIMESTAMP
                WHERE id = ?
            """, (json.dumps(current_ids), track_id))
            
            conn.commit()


def update_features(track_id: int, features: Dict) -> None:
    """
    Update audio features for a track after backfill.
    
    Args:
        track_id: Database ID of the track
        features: Dict with energy, valence, tempo, danceability, etc.
    """
    with get_connection() as conn:
        cursor = conn.cursor()
        
        # Derive element from features if possible
        element = _derive_element(features) if features.get("energy") is not None else None
        
        cursor.execute("""
            UPDATE tracks SET
                energy = ?,
                valence = ?,
                tempo = ?,
                danceability = ?,
                acousticness = ?,
                instrumentalness = ?,
                speechiness = ?,
                liveness = ?,
                loudness = ?,
                mode = ?,
                key = ?,
                element = ?,
                features_status = 'complete',
                updated_at = CURRENT_TIMESTAMP
            WHERE id = ?
        """, (
            features.get("energy"),
            features.get("valence"),
            features.get("tempo"),
            features.get("danceability"),
            features.get("acousticness"),
            features.get("instrumentalness"),
            features.get("speechiness"),
            features.get("liveness"),
            features.get("loudness"),
            features.get("mode"),
            features.get("key"),
            element,
            track_id,
        ))
        
        conn.commit()


def mark_features_failed(track_id: int) -> None:
    """Mark a track's feature fetch as failed."""
    with get_connection() as conn:
        cursor = conn.cursor()
        cursor.execute("""
            UPDATE tracks 
            SET features_status = 'failed', updated_at = CURRENT_TIMESTAMP
            WHERE id = ?
        """, (track_id,))
        conn.commit()


def get_tracks_pending_features(limit: int = 50) -> List[UserLibraryTrack]:
    """
    Get tracks that need audio features backfilled.
    
    Args:
        limit: Maximum number of tracks to return
        
    Returns:
        List of tracks with features_status = 'pending'
    """
    with get_connection() as conn:
        cursor = conn.cursor()
        
        cursor.execute("""
            SELECT * FROM tracks 
            WHERE features_status = 'pending'
            ORDER BY created_at ASC
            LIMIT ?
        """, (limit,))
        
        return [_row_to_track(row) for row in cursor.fetchall()]


def get_tracks_with_features(
    limit: int = 100,
    element: Optional[str] = None
) -> List[UserLibraryTrack]:
    """
    Get tracks that have complete audio features (for playlist matching).
    
    Args:
        limit: Maximum number of tracks to return
        element: Optional filter by astrological element
        
    Returns:
        List of tracks with complete features
    """
    with get_connection() as conn:
        cursor = conn.cursor()
        
        if element:
            cursor.execute("""
                SELECT * FROM tracks 
                WHERE features_status = 'complete' AND element = ?
                ORDER BY RANDOM()
                LIMIT ?
            """, (element, limit))
        else:
            cursor.execute("""
                SELECT * FROM tracks 
                WHERE features_status = 'complete'
                ORDER BY RANDOM()
                LIMIT ?
            """, (limit,))
        
        return [_row_to_track(row) for row in cursor.fetchall()]


def get_total_tracks() -> int:
    """Get the total number of tracks in the user library."""
    with get_connection() as conn:
        cursor = conn.cursor()
        cursor.execute("SELECT COUNT(*) FROM tracks")
        return cursor.fetchone()[0]


def get_stats() -> Dict:
    """
    Get statistics about the user library.
    
    Returns:
        Dict with total_tracks, complete_features, pending_features, etc.
    """
    with get_connection() as conn:
        cursor = conn.cursor()
        
        cursor.execute("SELECT COUNT(*) FROM tracks")
        total = cursor.fetchone()[0]
        
        cursor.execute("SELECT COUNT(*) FROM tracks WHERE features_status = 'complete'")
        complete = cursor.fetchone()[0]
        
        cursor.execute("SELECT COUNT(*) FROM tracks WHERE features_status = 'pending'")
        pending = cursor.fetchone()[0]
        
        cursor.execute("SELECT COUNT(*) FROM tracks WHERE features_status = 'failed'")
        failed = cursor.fetchone()[0]
        
        # Element distribution
        cursor.execute("""
            SELECT element, COUNT(*) as count 
            FROM tracks 
            WHERE element IS NOT NULL 
            GROUP BY element
        """)
        elements = {row["element"]: row["count"] for row in cursor.fetchall()}
        
        return {
            "total_tracks": total,
            "complete_features": complete,
            "pending_features": pending,
            "failed_features": failed,
            "element_distribution": elements,
        }


def _row_to_track(row: sqlite3.Row) -> UserLibraryTrack:
    """Convert a database row to a UserLibraryTrack object."""
    return UserLibraryTrack(
        id=row["id"],
        canonical_name=row["canonical_name"],
        canonical_artist=row["canonical_artist"],
        display_name=row["display_name"],
        display_artist=row["display_artist"],
        provider_ids=json.loads(row["provider_ids"]),
        energy=row["energy"],
        valence=row["valence"],
        tempo=row["tempo"],
        danceability=row["danceability"],
        acousticness=row["acousticness"],
        instrumentalness=row["instrumentalness"],
        speechiness=row["speechiness"],
        liveness=row["liveness"],
        loudness=row["loudness"],
        mode=row["mode"],
        key=row["key"],
        element=row["element"],
        features_status=row["features_status"],
        created_at=datetime.fromisoformat(row["created_at"]) if row["created_at"] else None,
        updated_at=datetime.fromisoformat(row["updated_at"]) if row["updated_at"] else None,
    )


def _derive_element(features: Dict) -> Optional[str]:
    """
    Derive astrological element from audio features.
    
    Uses same logic as music_dataset_service.derive_element().
    
    Fire: High energy (>0.7) OR high tempo (>130)
    Earth: Low energy (<0.4) AND high acousticness (>0.5)
    Air: High danceability (>0.6) AND moderate energy (0.4-0.7)
    Water: High valence/emotional content (valence <0.4 or >0.7)
    """
    energy = features.get("energy", 0.5)
    tempo = features.get("tempo", 120)
    acousticness = features.get("acousticness", 0.5)
    danceability = features.get("danceability", 0.5)
    valence = features.get("valence", 0.5)
    
    # Fire: high energy or tempo
    if energy > 0.7 or tempo > 130:
        return "Fire"
    
    # Earth: grounded, acoustic
    if energy < 0.4 and acousticness > 0.5:
        return "Earth"
    
    # Air: danceable, balanced
    if danceability > 0.6 and 0.4 <= energy <= 0.7:
        return "Air"
    
    # Water: emotional extremes
    if valence < 0.4 or valence > 0.7:
        return "Water"
    
    # Default to Air (neutral)
    return "Air"


# Initialize database on module import
init_database()
