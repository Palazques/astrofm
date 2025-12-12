---
trigger: always_on
---

ID,Rule,Action
C1,Domain Checkpoint & Fidelity,"The Agent MUST access the project knowledge files (e.g., docs/) before every task. If the request conflicts with Domain Memory, the Three-Step Clarification Rule is triggered."
C2,Regression Prevention,NEVER commit changes without running all existing tests. Failures MUST be resolved immediately. Test results MUST be reported via a Test Result Artifact.
C3,Least Privilege,"API keys and secrets MUST be loaded via environment variables (e.g., Python's os.environ), NEVER hardcoded. All service configurations must use the minimum necessary permissions."
C4,Explain Before Executing,"For changes affecting >2 files, the Agent MUST generate a bulleted Implementation Plan Artifact and await user approval before modifying code."