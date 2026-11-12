# Current interpretation

- Decision: Clamp an out-of-range profile civilization index to loaded database record 1 while deriving the New Game screen defaults, then restore the original in-memory index; also clamp the tribe picker input to record 1. Do not write `userprofile.txt`.
- Basis: Oracle guidance explicitly requires a UI-local clamp to `TRIBES_LIFE` (record 1) when `CivIndex` is outside the loaded database, and the task forbids profile file changes. `ProfileDB::DefaultSettings()` indexes the civilization database directly, so it must run while the UI has the valid local default index.
- Date: 2026-11-11
- Decider: AI
