# SLIC numeric input validation

## CURRENT — 2026-11-14

Tested Final-SDL executable SHA256:
`68CDF120FE75ED988D8697A9FBB48B364E78B9464698171D1429C8FF08DEF820`.
The same bytes are installed at `ctp2_program/ctp/ctp2.exe` in the game installation.
Both Final-SDL and Debug-SDL Win32 builds exited 0.

| Requirement / case | Observed result |
|---|---|
| SM-REQ-001: top-row 1 | Life Common page opens Bless confirmation |
| SM-REQ-001: top-row 2 | Opens Endurance confirmation |
| SM-REQ-001: top-row 3 | Opens Guardian Spirit confirmation |
| SM-REQ-001: keypad 3 | Same Guardian Spirit dialog pixels as top-row 3 |
| SM-REQ-002: matched click control | Native response button InjectPress for label 3 produces identical confirmation pixels |
| SM-REQ-003: independent confirmation | Confirmation remains visible; another 3 leaves it unchanged |
| SM-REQ-004: unmatched 9 | Original menu region is unchanged |
| SM-REQ-004: duplicates and multi-digit labels | Production binding functions compiled against button fixtures; duplicate keys and 10 gold stay unbound |
| SM-REQ-005: ordinary text input | Separate 1, 2, 3 key presses enter Alexander123 exactly once each in the leader field |
| Exact reported summon page | MomSummonPick_life_1 opens; 3 consumes that choice through the existing callback and closes the menu |
| Windowed resolution | Actual client 1024x768 on portrait desktop |
| Background isolation | Owned HWND remained at (-32000, -32000); no cursor-relative placement or global input |
| Installed runtime | Direct launch of installed ctp2.exe, without runtime overlay, captures the main menu and exits cleanly |

Runtime screenshots: source-worktree `.tmp/slic-acceptance/final_*.png`.
Final startup fixture: game-installation `Scenarios/mom/tools/uiwalk/runs/20261114-173058`.
Installed executable smoke: `Scenarios/mom/tools/uiwalk/runs/20261114-173552`.
Dialog comparison used pixels x=17..361, y=245..394, excluding the animated map.
Fixture setup opened existing scenario segments by name; acceptance keys used ordinary posted Windows keydown/up messages through SDL.

The first discovered defect was missing response action-key assignment; alertbox border ownership and uninitialized action keys were additional failures. Uninitialized keys allowed an unnumbered control to inherit a freed button's digit. All controls now initialize their key before LDL and SLIC bindings are applied.

Limits: gameplay acceptance used Final-SDL. Debug minimap assertions and existing-save compatibility were not validated by this feature check. Two autosaves changed during fresh-game setup were restored from their pre-run backups; no test process remains.

Sprawl review: removed the duplicate message scanner and obsolete PrintWindow capture path; reused response actions and the incumbent UIWalk test hook.
