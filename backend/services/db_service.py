"""
Database service for SQLite music dataset operations.
Provides connection management and query helpers.

S2: Documentation Rule - Clear docstrings for all functions.
"""
import sqlite3
from pathlib import Path
from typing import List, Dict, Optional, Tuple, Any
from contextlib import contextmanager


# =============================================================================
# DATABASE PATH
# =============================================================================

DATA_DIR = Path(__file__).parent.parent / "data"
DB_PATH = DATA_DIR / "music_dataset.db"


# =============================================================================
# CONNECTION MANAGEMENT
# =============================================================================

@contextmanager
def get_connection():
    """
    Get a database connection using context manager.
    
    Usage:
        with get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("SELECT * FROM tracks LIMIT 10")
    """
    conn = sqlite3.connect(str(DB_PATH))
    conn.row_factory = sqlite3.Row  # Enable dict-like access to rows
    try:
        yield conn
    finally:
        conn.close()


def execute_query(sql: str, params: tuple = ()) -> List[sqlite3.Row]:
    """
    Execute a SELECT query and return all results.
    
    Args:
        sql: SQL query string
        params: Query parameters
        
    Returns:
        List of Row objects (dict-like access)
    """
    with get_connection() as conn:
        cursor = conn.cursor()
        cursor.execute(sql, params)
        return cursor.fetchall()


def execute_query_one(sql: str, params: tuple = ()) -> Optional[sqlite3.Row]:
    """
    Execute a SELECT query and return first result.
    
    Args:
        sql: SQL query string
        params: Query parameters
        
    Returns:
        Single Row object or None
    """
    with get_connection() as conn:
        cursor = conn.cursor()
        cursor.execute(sql, params)
        return cursor.fetchone()


def execute_scalar(sql: str, params: tuple = ()) -> Any:
    """
    Execute a query and return single scalar value.
    
    Args:
        sql: SQL query (should return single column)
        params: Query parameters
        
    Returns:
        Single value
    """
    row = execute_query_one(sql, params)
    return row[0] if row else None


# =============================================================================
# TRACK QUERIES
# =============================================================================

def get_tracks_by_genre_sql(main_genre: str, limit: int = 100) -> List[sqlite3.Row]:
    """Get tracks matching a main genre."""
    return execute_query(
        "SELECT * FROM tracks WHERE main_genre = ? ORDER BY RANDOM() LIMIT ?",
        (main_genre, limit)
    )


def get_tracks_by_subgenre_sql(subgenre: str, limit: int = 100) -> List[sqlite3.Row]:
    """Get tracks matching a specific subgenre."""
    return execute_query(
        "SELECT * FROM tracks WHERE subgenre = ? ORDER BY RANDOM() LIMIT ?",
        (subgenre, limit)
    )


def get_tracks_by_element_sql(element: str, limit: int = 100) -> List[sqlite3.Row]:
    """Get tracks matching an astrological element."""
    return execute_query(
        "SELECT * FROM tracks WHERE element = ? ORDER BY RANDOM() LIMIT ?",
        (element, limit)
    )


def search_tracks_sql(query: str, limit: int = 20) -> List[sqlite3.Row]:
    """Search tracks by name or artist."""
    search_term = f"%{query}%"
    return execute_query(
        """
        SELECT * FROM tracks 
        WHERE track_name LIKE ? OR artists LIKE ?
        ORDER BY popularity DESC
        LIMIT ?
        """,
        (search_term, search_term, limit)
    )


def get_random_tracks_from_genres(
    genres: List[str],
    limit: int = 100
) -> List[sqlite3.Row]:
    """Get random tracks from multiple genres."""
    if not genres:
        return []
    
    placeholders = ",".join("?" * len(genres))
    return execute_query(
        f"SELECT * FROM tracks WHERE main_genre IN ({placeholders}) ORDER BY RANDOM() LIMIT ?",
        (*genres, limit)
    )


def get_tracks_with_filters(
    genres: Optional[List[str]] = None,
    subgenres: Optional[List[str]] = None,
    elements: Optional[List[str]] = None,
    min_energy: Optional[float] = None,
    max_energy: Optional[float] = None,
    min_valence: Optional[float] = None,
    max_valence: Optional[float] = None,
    min_tempo: Optional[float] = None,
    max_tempo: Optional[float] = None,
    limit: int = 100,
) -> List[sqlite3.Row]:
    """
    Get tracks with multiple filter criteria.
    
    Args:
        genres: List of main genres to include (OR logic)
        subgenres: List of subgenres to include (OR logic)
        elements: List of elements to include (OR logic)
        min_energy/max_energy: Energy range filter
        min_valence/max_valence: Valence range filter
        min_tempo/max_tempo: Tempo range filter
        limit: Maximum results
        
    Returns:
        List of matching track rows
    """
    conditions = []
    params = []
    
    if genres:
        placeholders = ",".join("?" * len(genres))
        conditions.append(f"main_genre IN ({placeholders})")
        params.extend(genres)
    
    if subgenres:
        placeholders = ",".join("?" * len(subgenres))
        conditions.append(f"subgenre IN ({placeholders})")
        params.extend(subgenres)
    
    if elements:
        placeholders = ",".join("?" * len(elements))
        conditions.append(f"element IN ({placeholders})")
        params.extend(elements)
    
    if min_energy is not None:
        conditions.append("energy >= ?")
        params.append(min_energy)
    
    if max_energy is not None:
        conditions.append("energy <= ?")
        params.append(max_energy)
    
    if min_valence is not None:
        conditions.append("valence >= ?")
        params.append(min_valence)
    
    if max_valence is not None:
        conditions.append("valence <= ?")
        params.append(max_valence)
    
    if min_tempo is not None:
        conditions.append("tempo >= ?")
        params.append(min_tempo)
    
    if max_tempo is not None:
        conditions.append("tempo <= ?")
        params.append(max_tempo)
    
    where_clause = " AND ".join(conditions) if conditions else "1=1"
    
    return execute_query(
        f"SELECT * FROM tracks WHERE {where_clause} ORDER BY RANDOM() LIMIT ?",
        (*params, limit)
    )


# =============================================================================
# STATISTICS
# =============================================================================

def get_total_tracks() -> int:
    """Get total number of tracks in database."""
    return execute_scalar("SELECT COUNT(*) FROM tracks") or 0


def get_genre_distribution() -> Dict[str, int]:
    """Get count of tracks per genre."""
    rows = execute_query(
        "SELECT main_genre, COUNT(*) as count FROM tracks GROUP BY main_genre ORDER BY count DESC"
    )
    return {row['main_genre']: row['count'] for row in rows}


def get_element_distribution() -> Dict[str, int]:
    """Get count of tracks per element."""
    rows = execute_query(
        "SELECT element, COUNT(*) as count FROM tracks GROUP BY element ORDER BY count DESC"
    )
    return {row['element']: row['count'] for row in rows}


def get_genre_index() -> Dict[str, int]:
    """Get list of all genres with their track counts."""
    return get_genre_distribution()


def get_subgenre_index() -> Dict[str, int]:
    """Get list of all subgenres with their track counts."""
    rows = execute_query(
        "SELECT subgenre, COUNT(*) as count FROM tracks GROUP BY subgenre ORDER BY count DESC"
    )
    return {row['subgenre']: row['count'] for row in rows}
