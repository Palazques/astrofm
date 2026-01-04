# Implementation Plan: Enhancing "Today's Reading" Experience

The current "Today's Reading" on the Home Screen provides generic astrological information. This plan upgrades it to a "Great" reading by adding actionable advice, clear energy labels, house localization, and retrograde synthesis following the "Event → Feeling → Action" framework.

## 1. Objectives
- **Actionable Advice:** Translate astrological transits into specific behavioral checks ("So What?").
- **Energy Context:** Clarify if the energy bar represents "Vitality" (user capacity) or "Volatility" (day intensity).
- **House Localization:** Identify exactly which area of the user's life (Natal Houses) is being activated.
- **Improved Synthesis:** Better integration of long-term retrogrades with daily transits.

## 2. Proposed Changes

### Backend (Python/FastAPI)
- **`backend/models/schemas.py`**:
    - Update `DailyReadingResponse` to include:
        - `actionable_advice` (str): Specific behavior suggestion.
        - `energy_label` (str): "Volatility Index" or "Vitality Battery".
        - `house_context` (str): The specific house triggered by the day's primary transit.
- **`backend/api/routes/ai.py`**:
    - Modify `/daily-reading` to calculate the user's natal house placements for the current Moon and Sun.
    - Pass this localization context to the AI service.
- **`backend/services/ai_service.py`**:
    - Update `generate_daily_reading` prompt to adopt the "Event → Feeling → Action" framework.
    - Added logic to select the appropriate `energy_label` based on current cosmic tension (high tension = Volatility, low tension = Vitality).

### Frontend (Flutter)
- **`frontend/lib/models/ai_responses.dart`**:
    - Add `actionableAdvice`, `energyLabel`, and `houseContext` to the `DailyReading` model.
- **`frontend/lib/screens/home_screen.dart`**:
    - Update `_buildHoroscopeCard` to:
        - Display the "So What?" advice in a dedicated, high-contrast section.
        - Show the dynamic `energyLabel` above the energy bar.
        - Include `houseContext` near the headline or as an info pill.

## 3. Implementation Steps
1. **Schema Update:** Modify Pydantic response models in the backend.
2. **Logic Expansion:** Update API route to calculate house placements.
3. **AI Prompt Refinement:** Redesign the horoscope generation prompt in `ai_service.py`.
4. **Dart Model Update:** Align frontend data classes with the new backend schema.
5. **UI Enhancement:** Update the Home Screen widget to present the rich data.

## 4. Verification Plan
- **Backend Test:** Execute `GET /api/ai/daily-reading` and verify the existence and quality of `actionable_advice` and `house_context`.
- **Frontend Check:** Verify the Home Screen displays the new labels and advice section correctly without UI overflow.
- **Regression:** Ensure the "Align" wheel and other AI-driven interpretations remain consistent with the new prompt guidelines.
