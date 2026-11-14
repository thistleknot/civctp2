# SLIC Numeric Choice Design

**Status:** Draft
**Decision:** [ADR-002](../../specs/ctp2-slic-numeric-choice.decision.md)
**Requirements:** [SM-REQ-001–SM-REQ-005](../reqs/ctp2-slic-numeric-choice.rst)

## Brownfield evidence

- `ctp2_code/gs/slic/SlicButton.h` stores the SLIC response name, segment, code offset, context, and message; it exposes `GetName()` and `Callback()`.
- `ctp2_code/gs/slic/SlicButton.cpp` runs the response's SLIC body in `Callback()`.
- `ctp2_code/ui/interface/messagemodal.cpp` builds clickable response buttons from `MessageData::GetButton(index)`.
- `ctp2_code/ui/interface/messageresponse.cpp` builds standard message response buttons and dispatches their SLIC response index.
- `ctp2_code/ui/aui_ctp2/keypress.cpp` currently has special yes/no and dismiss handling for modal messages but no generic numeric SLIC response dispatch.
- The installed MoM spellbook defines response captions `1` through `4` in `Scenarios/mom/scen0000/english/gamedata/scen_str.txt` and declares those SLIC buttons in its spellbook scripts.

## Proposed behavior boundary

The keyboard layer identifies an eligible active SLIC response only when the topmost input surface is the SLIC alertbox or SLIC message response. A response has a numeric input value only when its displayed SLIC button name is exactly one digit from 1 through 9. The input layer passes that value to the existing response activation path; it does not implement spell logic or infer which response to run from its position in a list.

The source `SlicButton` has no separate numeric field; its localized response label is already the visible key binding (the installed spellbook uses labels `1` through `4`). Resolve the exact label centrally and do not add new SLIC syntax or persisted fields.

## Response lifecycle

1. Keydown enters `ui_HandleKeypress`.
2. The topmost window is checked before a SLIC shortcut is considered.
3. The active SLIC response set is queried for the exact input value.
4. A single match dispatches through the same activation logic as clicking that response.
5. A duplicate or missing match leaves the original keyboard route intact.
6. Any follow-up SLIC alertbox/messagebox is handled as a new active response set.

## Integration contracts

| Existing element | Contract to reuse |
|---|---|
| `SlicButton::Callback()` | Executes the declared response body and segment context |
| `MessageModalResponseAction` | Preserves modal response completion and dismissal order |
| `MessageResponseAction` | Preserves standard response dispatch |
| `ui_HandleKeypress` | Owns key precedence and prevents global digit interception |

## Validation

Headless cases: unique input value, no match, duplicate values, response creates confirmation, ordinary text-field digit entry, mouse response regression, and repeated keydown. Check that each response body runs once and the follow-up screen remains available.

