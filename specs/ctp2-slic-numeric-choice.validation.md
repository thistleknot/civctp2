# SLIC Numeric Choice Validation

## CURRENT — 2026-11-15

**State:** Spec, source changes, static SLIC audit, Debug-SDL build, and install are complete; visible gameplay acceptance is pending with the operator at 800x600.

**User journey:** `J` opens the same sphere-specific spellbook hub as Workings. A numbered spell or creature choice follows its click action to detail/review; a separate `1` commits and `0` cancels. The More page preserves Very Rare and Magic Status navigation.

| Case | Evidence | Result |
|---|---|---|
| J opens the sphere-specific spellbook hub | `ctp2_code/ui/aui_ctp2/keypress.cpp` reads the visible player's `MomSphere` value and selects the matching existing `MomSpellHub_*` segment | Source change present; gameplay acceptance pending |
| Numeric key invokes the same visible button response as click | Shared key response path uses the existing button press completion; zero handles an explicit `0` response or unique visible X close action | Source/build present; operator check pending |
| Spell choice opens its detail/confirmation page | Updated system use case and existing spell response sequence | Spec/source reviewed; operator check pending |
| Summon picker opens creature detail before commit | `Scenarios/mom/scen0000/default/gamedata/mom_summon.slc` stages pending selection and routes 92 picker responses to 20 creature review pages | Static audit passed; operator check pending |
| Summon confirmation and cancellation | Review page `1` commits after state/affordability checks; `0` clears pending choice and returns to the matching hub | Static source inspection passed; operator check pending |
| More preserves Very Rare and Magic Status | Five sphere hubs open shared More page; More links Very Rare, Magic Status, and Back; four localization keys are unique | Static SLIC audit passed |
| Requirement and use-case validation | UC-007 through UC-010 strict validation: 4 files, 0 errors, 0 warnings; SM-REQ-016 EARS: 1/1 | Passed |
| Debug-SDL build and installed executable identity | Source and installed `ctp2-dbg.exe` SHA-256: `0E16588EB015DDA7E16366B2CE275255D7E74D7FE2316F33ADBAC7ECA0C3D5A0`; backup: `.tmp/clean-build/ctp2-dbg.exe.before-spellbook-j-route-20261115.exe` | Hashes match; build/install verified |
| Full visible user journey | No game/UIWalk execution was performed | Operator acceptance pending at 800x600 |

The project-scoped Specs MCP registry tools are absent from the live tool catalog; validated project files remain the source artifacts. The deferred UIWalk unit-test/spec task is recorded in the workspace Todo list.

Sprawl review: nothing to collapse.

See [the 2026-11-14 receipt](ctp2-slic-numeric-choice.validation-2026-11-14.md) for its historical controls, executable details, and runtime images.

