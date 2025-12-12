# Technical Stack and Architecture Directives

## I. Frontend Stack (Dart/Flutter)
* **Framework:** Flutter (Cross-platform deployment).
* **Responsibility:** Handling UI/UX rendering, local state management, and communication with the Python Backend API.
* **Security:** Must securely transmit user input (like birth details) to the backend via HTTPS/TLS.

## II. Backend Stack (Python/Flask API)
* **Framework:** Flask API (Python-based).
* **Responsibility:** **All heavy logic**—Astrological Calculations, Data Sonification, Harmonic Analysis, Playlist Parameter Translation, and API key management.
* **Database:** Firebase (Authentication and primary data storage).
* **Security Directive:** Must implement **H2 (Input Validation)** using Flask/Pydantic models for every incoming API request.

## III. Third-Party Integrations
* **Astrology:** Swiss Ephemeris (API or JS Library for planetary calculations).
* **Music Streaming:** Spotify API (Primary), Apple Music API, YouTube Music API.
* **Security Directive (C3):** All API keys (Ephemeris, Spotify, etc.) MUST be loaded using **environment variables** in the Flask environment.

## IV. Core Architecture Directives
* **Separation of Concerns:** Strict rule: Flutter handles visual presentation; Flask handles calculation and data processing. UI logic must NOT contain hardcoded astrological rules.
* **Communication:** All communication between Flutter and Flask must be via **secure HTTPS endpoints**.
