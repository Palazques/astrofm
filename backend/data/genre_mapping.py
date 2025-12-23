"""
Genre mapping for the 114K music dataset.
Maps 114 dataset genres → 24 app main genres with subgenre associations.

H4: Astrology Logic Fidelity - Genre mappings must align with user-approved structure.
S2: Documentation Rule - Clear docstrings for mapping logic.
"""
from typing import Dict, Tuple, List

# =============================================================================
# MAIN GENRES (24 total) - Restructured per user approval
# =============================================================================

MAIN_GENRES: List[str] = [
    "Pop",
    "Rock",
    "Country",
    "Electronic",
    "Hip Hop / R&B",
    "Indie",
    "Jazz",
    "Classical",
    "Latin",
    "Folk",
    "World Music",
    "Soul",
    "Metal",
    "Reggae",
    "Blues",
    "Funk",
    "Punk",
    "Afrobeats",
    "Disco",
    "Religious",
    "Soundtrack",
    "K-Pop",
    "J-Pop",
    "New Age",
]

# =============================================================================
# SUBGENRES BY MAIN GENRE
# =============================================================================

SUBGENRES: Dict[str, List[str]] = {
    "Pop": ["Dance Pop", "Synth-Pop", "K-Pop", "J-Pop", "Electropop", "Indie Pop", "Art Pop"],
    "Rock": ["Alternative Rock", "Classic Rock", "Hard Rock", "Indie Rock", "Punk Rock", "Grunge", "Progressive Rock"],
    "Country": ["Contemporary Country", "Country Pop", "Americana", "Outlaw Country", "Bluegrass", "Alt-Country", "Country Rock"],
    "Electronic": ["EDM", "House", "Techno", "Trance", "Dubstep", "Drum & Bass", "Ambient"],
    "Hip Hop / R&B": ["Trap", "Boom Bap", "Alternative Hip Hop", "Neo-Soul", "Contemporary R&B", "Drill", "Conscious Hip Hop"],
    "Indie": ["Indie Rock", "Indie Pop", "Indie Folk", "Indie Electronic", "Dream Pop", "Lo-Fi", "Shoegaze"],
    "Jazz": ["Bebop", "Swing", "Cool Jazz", "Fusion", "Smooth Jazz", "Hard Bop", "Free Jazz"],
    "Classical": ["Baroque", "Classical Period", "Romantic", "Contemporary Classical", "Minimalism", "Chamber Music", "Opera"],
    "Latin": ["Reggaeton", "Latin Pop", "Salsa", "Bachata", "Regional Mexican", "Latin Trap", "Merengue"],
    "Folk": ["Traditional Folk", "Contemporary Folk", "Folk Rock", "Americana", "Celtic Folk", "Singer-Songwriter", "Acoustic Folk"],
    "World Music": ["World Music"],  # Self-referencing single subgenre
    "Soul": ["Classic Soul", "Neo-Soul", "Motown", "Southern Soul", "Psychedelic Soul", "Funk Soul", "Contemporary Soul"],
    "Metal": ["Heavy Metal", "Thrash Metal", "Death Metal", "Black Metal", "Metalcore", "Progressive Metal", "Doom Metal"],
    "Reggae": ["Roots Reggae", "Dancehall", "Dub", "Lovers Rock", "Ska", "Rocksteady", "Reggae Fusion"],
    "Blues": ["Delta Blues", "Chicago Blues", "Texas Blues", "Electric Blues", "Blues Rock", "Country Blues", "Contemporary Blues"],
    "Funk": ["Classic Funk", "P-Funk", "Funk Rock", "Electro-Funk", "Soul Funk", "Jazz Funk", "Funk Pop"],
    "Punk": ["Hardcore Punk", "Pop Punk", "Post-Punk", "Punk Rock", "Anarcho-Punk", "Skate Punk", "Garage Punk"],
    "Afrobeats": ["Afropop", "Afro-Fusion", "Afro-House", "Alté", "Afro-Trap", "Azonto", "Highlife"],
    "Disco": ["Classic Disco", "Euro Disco", "Italo Disco", "Nu-Disco", "Disco Funk", "Dance Disco", "Post-Disco"],
    "Religious": ["Gospel", "Contemporary Christian", "Traditional Gospel", "Urban Gospel", "Southern Gospel", "Praise & Worship", "Gospel Soul"],
    "Soundtrack": ["Film Score", "Television Score", "Video Game Music", "Orchestral Score", "Ambient Score", "Cinematic", "Trailer Music"],
    "K-Pop": ["Idol Pop", "K-Rap", "K-R&B", "Dance K-Pop", "Experimental K-Pop", "Ballad K-Pop", "Electronic K-Pop"],
    "J-Pop": ["Idol Pop", "J-Rock", "City Pop", "Anime Soundtrack", "J-Electronic", "J-R&B", "J-Folk"],
    "New Age": ["Dark Ambient", "Space Ambient", "Drone", "Ambient Electronic", "Nature Ambient", "Meditation", "Experimental Ambient"],
}

# =============================================================================
# DATASET GENRE → (MAIN GENRE, SUBGENRE) MAPPING
# Maps all 114 genres from the Spotify dataset to app structure
# =============================================================================

GENRE_MAPPING: Dict[str, Tuple[str, str]] = {
    # Acoustic/Folk → Folk (formerly Acoustic main genre)
    "acoustic": ("Folk", "Acoustic Folk"),
    "singer-songwriter": ("Folk", "Singer-Songwriter"),
    
    # Alt-rock → Rock
    "alt-rock": ("Rock", "Alternative Rock"),
    "alternative": ("Rock", "Alternative Rock"),
    
    # Ambient → New Age (meditation category)
    "ambient": ("New Age", "Dark Ambient"),
    
    # Anime → J-Pop
    "anime": ("J-Pop", "Anime Soundtrack"),
    
    # Afrobeat/African → Afrobeats
    "afrobeat": ("Afrobeats", "Afropop"),
    
    # Black Metal → Metal
    "black-metal": ("Metal", "Black Metal"),
    
    # Bluegrass → Country (per user's clarification)
    "bluegrass": ("Country", "Bluegrass"),
    
    # Blues
    "blues": ("Blues", "Chicago Blues"),
    
    # Brazil → Latin
    "brazil": ("Latin", "Latin Pop"),
    
    # Breakbeat → Electronic
    "breakbeat": ("Electronic", "Drum & Bass"),
    
    # British → Rock (British rock)
    "british": ("Rock", "Classic Rock"),
    
    # Cantopop/Mandopop → Pop
    "cantopop": ("Pop", "Art Pop"),
    "mandopop": ("Pop", "Art Pop"),
    
    # Chicago House → Electronic
    "chicago-house": ("Electronic", "House"),
    
    # Children → Soundtrack (educational/kids)
    "children": ("Soundtrack", "Film Score"),
    
    # Chill → New Age
    "chill": ("New Age", "Ambient Electronic"),
    
    # Classical
    "classical": ("Classical", "Classical Period"),
    "opera": ("Classical", "Opera"),
    
    # Club → Electronic
    "club": ("Electronic", "EDM"),
    
    # Comedy → Soundtrack
    "comedy": ("Soundtrack", "Film Score"),
    
    # Country → Country
    "country": ("Country", "Contemporary Country"),
    
    # Dance → Electronic/Pop
    "dance": ("Electronic", "EDM"),
    "dancehall": ("Reggae", "Dancehall"),
    
    # Death Metal → Metal
    "death-metal": ("Metal", "Death Metal"),
    
    # Deep House → Electronic
    "deep-house": ("Electronic", "House"),
    
    # Detroit Techno → Electronic
    "detroit-techno": ("Electronic", "Techno"),
    
    # Disco
    "disco": ("Disco", "Classic Disco"),
    
    # Disney → Soundtrack
    "disney": ("Soundtrack", "Film Score"),
    
    # Drum and Bass → Electronic
    "drum-and-bass": ("Electronic", "Drum & Bass"),
    
    # Dub → Reggae
    "dub": ("Reggae", "Dub"),
    
    # Dubstep → Electronic
    "dubstep": ("Electronic", "Dubstep"),
    
    # EDM → Electronic
    "edm": ("Electronic", "EDM"),
    
    # Electro → Electronic
    "electro": ("Electronic", "EDM"),
    
    # Electronic → Electronic
    "electronic": ("Electronic", "Ambient"),
    
    # Emo → Punk/Rock
    "emo": ("Punk", "Pop Punk"),
    
    # Folk → Country (per user's clarification - dataset folk maps to Country)
    "folk": ("Country", "Americana"),
    
    # French → Pop
    "french": ("Pop", "Art Pop"),
    
    # Funk → Funk
    "funk": ("Funk", "Classic Funk"),
    
    # Garage → Electronic
    "garage": ("Electronic", "House"),
    
    # German → Pop/Rock
    "german": ("Pop", "Art Pop"),
    
    # Gospel → Religious
    "gospel": ("Religious", "Gospel"),
    
    # Goth → Rock
    "goth": ("Rock", "Alternative Rock"),
    
    # Grindcore → Metal
    "grindcore": ("Metal", "Death Metal"),
    
    # Groove → Funk
    "groove": ("Funk", "Classic Funk"),
    
    # Grunge → Rock
    "grunge": ("Rock", "Grunge"),
    
    # Guitar → Rock
    "guitar": ("Rock", "Classic Rock"),
    
    # Happy → Pop
    "happy": ("Pop", "Dance Pop"),
    
    # Hard Rock → Rock
    "hard-rock": ("Rock", "Hard Rock"),
    
    # Hardcore → Punk
    "hardcore": ("Punk", "Hardcore Punk"),
    
    # Hardstyle → Electronic
    "hardstyle": ("Electronic", "EDM"),
    
    # Heavy Metal → Metal
    "heavy-metal": ("Metal", "Heavy Metal"),
    
    # Hip Hop → Hip Hop / R&B
    "hip-hop": ("Hip Hop / R&B", "Trap"),
    
    # Honky Tonk → Country
    "honky-tonk": ("Country", "Outlaw Country"),
    
    # House → Electronic
    "house": ("Electronic", "House"),
    
    # IDM → Electronic
    "idm": ("Electronic", "Ambient"),
    
    # Indian → World Music
    "indian": ("World Music", "World Music"),
    
    # Indie → Indie
    "indie": ("Indie", "Indie Rock"),
    "indie-pop": ("Indie", "Indie Pop"),
    
    # Industrial → Electronic/Metal
    "industrial": ("Metal", "Heavy Metal"),
    
    # Iranian → World Music
    "iranian": ("World Music", "World Music"),
    
    # J-Dance → Electronic
    "j-dance": ("Electronic", "EDM"),
    
    # J-Idol → J-Pop
    "j-idol": ("J-Pop", "Idol Pop"),
    
    # J-Pop → J-Pop
    "j-pop": ("J-Pop", "Idol Pop"),
    
    # J-Rock → J-Pop
    "j-rock": ("J-Pop", "J-Rock"),
    
    # Jazz → Jazz
    "jazz": ("Jazz", "Cool Jazz"),
    
    # K-Pop → K-Pop
    "k-pop": ("K-Pop", "Idol Pop"),
    
    # Kids → Soundtrack
    "kids": ("Soundtrack", "Film Score"),
    
    # Latin → Latin
    "latin": ("Latin", "Latin Pop"),
    "latino": ("Latin", "Latin Pop"),
    "salsa": ("Latin", "Salsa"),
    
    # Malay → World Music
    "malay": ("World Music", "World Music"),
    
    # Metalcore → Metal
    "metalcore": ("Metal", "Metalcore"),
    
    # Minimal Techno → Electronic
    "minimal-techno": ("Electronic", "Techno"),
    
    # MPB (Música Popular Brasileira) → Latin
    "mpb": ("Latin", "Latin Pop"),
    
    # New Age → New Age
    "new-age": ("New Age", "Meditation"),
    
    # New Wave → Rock
    "new-wave": ("Rock", "Alternative Rock"),
    
    # Opera → Classical
    "pagode": ("Latin", "Latin Pop"),
    
    # Party → Pop
    "party": ("Pop", "Dance Pop"),
    
    # Philippines OPM → Pop
    "philippines-opm": ("Pop", "Art Pop"),
    
    # Piano → Classical
    "piano": ("Classical", "Minimalism"),
    
    # Pop → Pop
    "pop": ("Pop", "Dance Pop"),
    "pop-film": ("Soundtrack", "Film Score"),
    "power-pop": ("Pop", "Synth-Pop"),
    
    # Progressive House → Electronic
    "progressive-house": ("Electronic", "House"),
    
    # Psych Rock → Rock
    "psych-rock": ("Rock", "Progressive Rock"),
    
    # Punk → Punk
    "punk": ("Punk", "Punk Rock"),
    "punk-rock": ("Punk", "Punk Rock"),
    
    # R&B → Hip Hop / R&B
    "r-n-b": ("Hip Hop / R&B", "Contemporary R&B"),
    
    # Rainy Day → New Age
    "rainy-day": ("New Age", "Ambient Electronic"),
    
    # Reggae → Reggae
    "reggae": ("Reggae", "Roots Reggae"),
    "reggaeton": ("Latin", "Reggaeton"),
    
    # Rock → Rock
    "rock": ("Rock", "Classic Rock"),
    "rock-n-roll": ("Rock", "Classic Rock"),
    
    # Romance → Pop
    "romance": ("Pop", "Art Pop"),
    "romantic": ("Pop", "Art Pop"),
    
    # Sad → Pop/Indie
    "sad": ("Indie", "Dream Pop"),
    
    # Samba → Latin
    "samba": ("Latin", "Latin Pop"),
    
    # Sertanejo → Country/Latin
    "sertanejo": ("Country", "Contemporary Country"),
    
    # Show Tunes → Soundtrack
    "show-tunes": ("Soundtrack", "Film Score"),
    
    # Singer-Songwriter → Folk
    
    # Ska → Reggae
    "ska": ("Reggae", "Ska"),
    
    # Sleep → New Age
    "sleep": ("New Age", "Meditation"),
    
    # Soul → Soul
    "soul": ("Soul", "Classic Soul"),
    
    # Soundtracks → Soundtrack
    "soundtracks": ("Soundtrack", "Film Score"),
    
    # Spanish → Latin
    "spanish": ("Latin", "Latin Pop"),
    
    # Study → New Age
    "study": ("New Age", "Ambient Electronic"),
    
    # Summer → Pop
    "summer": ("Pop", "Dance Pop"),
    
    # Swedish → Pop
    "swedish": ("Pop", "Synth-Pop"),
    
    # Synth Pop → Pop
    "synth-pop": ("Pop", "Synth-Pop"),
    
    # Tango → Latin
    "tango": ("Latin", "Regional Mexican"),
    
    # Techno → Electronic (Trance subgenres now under Electronic per user)
    "techno": ("Electronic", "Techno"),
    
    # Trance → Electronic (no longer standalone genre per user request)
    "trance": ("Electronic", "Trance"),
    
    # Trip Hop → Electronic
    "trip-hop": ("Electronic", "Ambient"),
    
    # Turkish → World Music
    "turkish": ("World Music", "World Music"),
    
    # Work Out → Pop/Electronic
    "work-out": ("Electronic", "EDM"),
    
    # World Music → World Music
    "world-music": ("World Music", "World Music"),
}

# =============================================================================
# RELATED GENRES - For occasional inclusion (0.3x weight)
# Based on audio feature similarity
# =============================================================================

RELATED_GENRES: Dict[str, List[str]] = {
    "Pop": ["Indie", "K-Pop", "J-Pop", "Disco"],
    "Rock": ["Punk", "Metal", "Indie", "Blues"],
    "Country": ["Folk", "Blues", "Rock"],
    "Electronic": ["Disco", "Pop", "New Age"],
    "Hip Hop / R&B": ["Soul", "Funk", "Pop"],
    "Indie": ["Rock", "Folk", "Pop"],
    "Jazz": ["Soul", "Blues", "Funk", "Classical"],
    "Classical": ["Soundtrack", "New Age", "Jazz"],
    "Latin": ["Reggae", "Pop", "Soul"],
    "Folk": ["Country", "Indie", "Rock"],
    "World Music": ["Latin", "Jazz", "Folk"],
    "Soul": ["Funk", "Hip Hop / R&B", "Jazz"],
    "Metal": ["Rock", "Punk"],
    "Reggae": ["Latin", "Soul", "Funk"],
    "Blues": ["Jazz", "Soul", "Rock", "Country"],
    "Funk": ["Soul", "Disco", "Hip Hop / R&B"],
    "Punk": ["Rock", "Metal", "Indie"],
    "Afrobeats": ["Latin", "Hip Hop / R&B", "Reggae"],
    "Disco": ["Funk", "Pop", "Electronic"],
    "Religious": ["Soul", "Country", "Folk"],
    "Soundtrack": ["Classical", "New Age", "Pop"],
    "K-Pop": ["Pop", "Hip Hop / R&B", "Electronic"],
    "J-Pop": ["Pop", "Rock", "Electronic"],
    "New Age": ["Classical", "Electronic", "Soundtrack"],
}

# =============================================================================
# PREFERENCE WEIGHTS
# =============================================================================

class PreferenceWeights:
    """Weight multipliers for playlist generation."""
    SUBGENRE_SELECTED = 2.0    # User explicitly selected this subgenre
    MAIN_GENRE_ONLY = 1.0      # User selected main genre (no specific subgenre)
    RELATED_GENRE = 0.3        # Related genre for occasional variety


def get_app_genre(dataset_genre: str) -> Tuple[str, str]:
    """
    Map a dataset genre to the app's main genre and subgenre.
    
    Args:
        dataset_genre: The genre string from the dataset (e.g., "acoustic")
        
    Returns:
        Tuple of (main_genre, subgenre) for the app
        Defaults to ("World Music", "World Music") if unknown
    """
    return GENRE_MAPPING.get(dataset_genre.lower(), ("World Music", "World Music"))


def get_related_genres(main_genre: str) -> List[str]:
    """
    Get list of related genres for occasional variety in playlists.
    
    Args:
        main_genre: The main genre (e.g., "Electronic")
        
    Returns:
        List of related genre names
    """
    return RELATED_GENRES.get(main_genre, [])


def get_subgenres(main_genre: str) -> List[str]:
    """
    Get list of subgenres for a main genre.
    
    Args:
        main_genre: The main genre (e.g., "Electronic")
        
    Returns:
        List of subgenre names
    """
    return SUBGENRES.get(main_genre, [])
