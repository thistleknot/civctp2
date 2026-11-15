# SLIC Numeric Choice Validation — Historical

This is the 2026-11-14 receipt retained for the numeric key dispatch change. Its passing cases cover the spellbook route and response-button activation. It did not prove that the reported summon-unit picker advances to a detail page or that a second numeric response submits the command.

Tested Final-SDL executable SHA256:
`68CDF120FE75ED988D8697A9FBB48B364E78B9464698171D1429C8FF08DEF820`.
The same bytes were installed at `ctp2_program/ctp/ctp2.exe`.

| Earlier case | Earlier observation |
|---|---|
| Spellbook top-row 1, 2, and 3 | Each opened its matching spell detail/confirmation page. |
| Keypad 3 | Same detail screen as top-row 3. |
| Unmatched 9 | Original menu remained visible. |
| Repeated 3 on detail screen | Detail screen remained visible. |
| Ordinary text field | Digits appended once each. |
| `MomSummonPick_life_1` | Choice callback ran and closed the picker. |
| Windowed geometry | Actual client was 1024x768. |
| Installed executable startup | Normal installed `ctp2.exe` launched and captured the main menu. |

Evidence images remain in source-worktree `.tmp/slic-acceptance/final_*.png`.
The `final_key3_confirmation.png` image is the spellbook detail screen; it is
not evidence that the summon picker opens a detail screen.

Historical 2026-11-15 receipt note: sprawl review reported two paths collapsed in that prior iteration.
