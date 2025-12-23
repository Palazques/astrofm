"""
Database initialization script for music dataset.
Migrates the CSV dataset to SQLite for improved query performance.

Usage: python -m data.db_init

H2: Input Validation - Schema enforces data types.
S2: Documentation Rule - Clear docstrings for all functions.
"""
import csv
import sqlite3
from pathlib import Path
from typing import Optional

from data.genre_mapping import get_app_genre


# =============================================================================
# PATHS
# =============================================================================

DATA_DIR = Path(__file__).parent
CSV_PATH = DATA_DIR / "music_dataset.csv"
DB_PATH = DATA_DIR / "music_dataset.db"


# =============================================================================
# SCHEMA
# =============================================================================

CREATE_TRACKS_TABLE = """
CREATE TABLE IF NOT EXISTS tracks (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    track_id TEXT NOT NULL,
    artists TEXT,
    album_name TEXT,
    track_name TEXT,
    popularity INTEGER DEFAULT 0,
    duration_ms INTEGER DEFAULT 0,
    explicit INTEGER DEFAULT 0,
    danceability REAL DEFAULT 0,
    energy REAL DEFAULT 0,
    key INTEGER DEFAULT 0,
    loudness REAL DEFAULT 0,
    mode INTEGER DEFAULT 0,
    speechiness REAL DEFAULT 0,
    acousticness REAL DEFAULT 0,
    instrumentalness REAL DEFAULT 0,
    liveness REAL DEFAULT 0,
    valence REAL DEFAULT 0,
    tempo REAL DEFAULT 0,
    time_signature INTEGER DEFAULT 4,
    dataset_genre TEXT,
    main_genre TEXT,
    subgenre TEXT,
    element TEXT
);
"""

CREATE_INDEXES = [
    "CREATE INDEX IF NOT EXISTS idx_main_genre ON tracks(main_genre);",
    "CREATE INDEX IF NOT EXISTS idx_subgenre ON tracks(subgenre);",
    "CREATE INDEX IF NOT EXISTS idx_element ON tracks(element);",
    "CREATE INDEX IF NOT EXISTS idx_tempo ON tracks(tempo);",
    "CREATE INDEX IF NOT EXISTS idx_energy ON tracks(energy);",
    "CREATE INDEX IF NOT EXISTS idx_valence ON tracks(valence);",
    "CREATE INDEX IF NOT EXISTS idx_popularity ON tracks(popularity);",
]


# =============================================================================
# ELEMENT DERIVATION (matches music_dataset_service.py logic)
# =============================================================================

def derive_element(
    energy: float,
    valence: float,
    danceability: float,
    acousticness: float,
    tempo: float,
) -> str:
    """
    Derive astrological element from audio features.
    
    Fire: High energy (>0.7) and high valence (>0.6)
    Earth: High acousticness (>0.5) and moderate tempo (80-120 BPM)
    Air: High danceability (>0.6) and moderate energy (0.4-0.7)
    Water: High acousticness (>0.5) or low energy (<0.4) with low valence (<0.4)
    """
    # Fire: High energy + positive mood
    if energy > 0.7 and valence > 0.6:
        return "Fire"
    
    # Water: Low energy + melancholic mood
    if (energy < 0.4 and valence < 0.4) or (acousticness > 0.6 and valence < 0.4):
        return "Water"
    
    # Earth: Grounded, stable, acoustic
    if acousticness > 0.5 and 80 <= tempo <= 120:
        return "Earth"
    
    # Air: Light, danceable, moderate energy
    if danceability > 0.6 and 0.4 <= energy <= 0.7:
        return "Air"
    
    # Default based on energy level
    if energy > 0.6:
        return "Fire"
    elif energy < 0.3:
        return "Water"
    elif acousticness > 0.4:
        return "Earth"
    else:
        return "Air"


# =============================================================================
# MIGRATION
# =============================================================================

def create_database() -> sqlite3.Connection:
    """Create database and tables."""
    conn = sqlite3.connect(str(DB_PATH))
    cursor = conn.cursor()
    
    # Create table
    cursor.execute(CREATE_TRACKS_TABLE)
    
    # Create indexes
    for idx_sql in CREATE_INDEXES:
        cursor.execute(idx_sql)
    
    conn.commit()
    return conn


def safe_float(value: str, default: float = 0.0) -> float:
    """Safely parse float from string."""
    try:
        return float(value) if value else default
    except (ValueError, TypeError):
        return default


def safe_int(value: str, default: int = 0) -> int:
    """Safely parse int from string."""
    try:
        return int(value) if value else default
    except (ValueError, TypeError):
        return default


def migrate_csv_to_sqlite(conn: Optional[sqlite3.Connection] = None) -> int:
    """
    Migrate all tracks from CSV to SQLite database.
    
    Returns:
        Number of tracks migrated
    """
    should_close = conn is None
    if conn is None:
        conn = create_database()
    
    cursor = conn.cursor()
    
    # Check if already migrated
    cursor.execute("SELECT COUNT(*) FROM tracks")
    existing_count = cursor.fetchone()[0]
    if existing_count > 0:
        print(f"Database already contains {existing_count} tracks. Skipping migration.")
        if should_close:
            conn.close()
        return existing_count
    
    # Read CSV and insert rows
    insert_sql = """
    INSERT INTO tracks (
        track_id, artists, album_name, track_name, popularity, duration_ms,
        explicit, danceability, energy, key, loudness, mode, speechiness,
        acousticness, instrumentalness, liveness, valence, tempo, time_signature,
        dataset_genre, main_genre, subgenre, element
    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    """
    
    rows_to_insert = []
    count = 0
    
    with open(CSV_PATH, 'r', encoding='utf-8', errors='replace') as f:
        reader = csv.DictReader(f)
        for row in reader:
            try:
                # Parse audio features
                energy = safe_float(row.get('energy', 0))
                valence = safe_float(row.get('valence', 0))
                danceability = safe_float(row.get('danceability', 0))
                acousticness = safe_float(row.get('acousticness', 0))
                tempo = safe_float(row.get('tempo', 0))
                
                # Derive genre and element
                dataset_genre = row.get('track_genre', '')
                main_genre, subgenre = get_app_genre(dataset_genre)
                element = derive_element(energy, valence, danceability, acousticness, tempo)
                
                rows_to_insert.append((
                    row.get('track_id', ''),
                    row.get('artists', ''),
                    row.get('album_name', ''),
                    row.get('track_name', ''),
                    safe_int(row.get('popularity', 0)),
                    safe_int(row.get('duration_ms', 0)),
                    1 if row.get('explicit', 'False').lower() == 'true' else 0,
                    danceability,
                    energy,
                    safe_int(row.get('key', 0)),
                    safe_float(row.get('loudness', 0)),
                    safe_int(row.get('mode', 0)),
                    safe_float(row.get('speechiness', 0)),
                    acousticness,
                    safe_float(row.get('instrumentalness', 0)),
                    safe_float(row.get('liveness', 0)),
                    valence,
                    tempo,
                    safe_int(row.get('time_signature', 4)),
                    dataset_genre,
                    main_genre,
                    subgenre,
                    element,
                ))
                count += 1
                
                # Batch insert every 5000 rows
                if len(rows_to_insert) >= 5000:
                    cursor.executemany(insert_sql, rows_to_insert)
                    conn.commit()
                    print(f"Inserted {count} tracks...")
                    rows_to_insert = []
                    
            except Exception as e:
                print(f"Error processing row: {e}")
                continue
    
    # Insert remaining rows
    if rows_to_insert:
        cursor.executemany(insert_sql, rows_to_insert)
        conn.commit()
    
    print(f"Migration complete: {count} tracks inserted.")
    
    if should_close:
        conn.close()
    
    return count


def get_stats() -> dict:
    """Get database statistics."""
    conn = sqlite3.connect(str(DB_PATH))
    cursor = conn.cursor()
    
    stats = {}
    
    # Total tracks
    cursor.execute("SELECT COUNT(*) FROM tracks")
    stats['total_tracks'] = cursor.fetchone()[0]
    
    # Genre distribution
    cursor.execute("""
        SELECT main_genre, COUNT(*) as count 
        FROM tracks 
        GROUP BY main_genre 
        ORDER BY count DESC
    """)
    stats['genre_distribution'] = dict(cursor.fetchall())
    
    # Element distribution
    cursor.execute("""
        SELECT element, COUNT(*) as count 
        FROM tracks 
        GROUP BY element 
        ORDER BY count DESC
    """)
    stats['element_distribution'] = dict(cursor.fetchall())
    
    conn.close()
    return stats


# =============================================================================
# MAIN
# =============================================================================

if __name__ == "__main__":
    print(f"CSV path: {CSV_PATH}")
    print(f"DB path: {DB_PATH}")
    print()
    
    # Run migration
    count = migrate_csv_to_sqlite()
    
    # Print stats
    if count > 0:
        print()
        stats = get_stats()
        print(f"Total tracks: {stats['total_tracks']}")
        print(f"Genres: {len(stats['genre_distribution'])}")
        print(f"Elements: {stats['element_distribution']}")
