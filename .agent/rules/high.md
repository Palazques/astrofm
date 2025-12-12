---
trigger: always_on
---

ID,Rule,Action
H1,Isolation Principle,"Limit code changes to the smallest necessary scope. Do NOT refactor or touch adjacent, unrelated code unless it is a necessary dependency update."
H2,Input Validation,"All data from the Flutter frontend and external APIs (birth data, user preferences) MUST be validated and sanitized on the FastAPI backend using strict typing and validation models (e.g., Pydantic)."
H3,Unit Test Creation,"Any new Python function for Astrology Logic or Vibe Code Aggregation MUST have a corresponding, specific Unit Test created at the same time."
H4,Astrology Logic Fidelity,"When implementing a calculation (e.g., Orb of Influence, Aspect Mapping), the Python code MUST be cross-referenced against the descriptive logic in docs/astrology_vibe_logic.md to ensure perfect fidelity."