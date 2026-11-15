# SLIC Numeric Choice Design

**Status:** Implemented and verified in Final-SDL; see [runtime receipt](../../specs/ctp2-slic-numeric-choice.validation.md).
**Decision:** [ADR-002](../../specs/ctp2-slic-numeric-choice.decision.md)
**Requirements:** [SM-REQ-001–SM-REQ-005](../reqs/ctp2-slic-numeric-choice.rst)

## Brownfield evidence

- `ctp2_code/gs/slic/SlicButton.h` stores the SLIC response name, segment, code offset, context, and message; it exposes `GetName()` and `Callback()`.
- `ctp2_code/gs/slic/SlicButton.cpp` runs the response's SLIC body in `Callback()`.
- `ctp2_code/ui/interface/messagemodal.cpp` builds clickable response buttons from `MessageData::GetButton(index)`.
- `ctp2_code/ui/interface/messageresponse.cpp` builds standard message response buttons and dispatches their SLIC response index.
- `ctp2_code/ctp/civ3_main.cpp` translates SDL keydown events before calling `ui_HandleKeypress`; before the fix it maps letters and navigation keys but omits top-row and keypad digits, leaving `wParam` zero for a physical digit keydown.
- The existing draft PR #474 (`7b4cab780`) assigns action keys to SLIC response buttons in `messageresponse.cpp` and `messagemodal.cpp`; it is not an ancestor of this branch and had no live-game verification.
- `ctp2_code/ui/aui_common/aui_control.cpp` dispatches a matching action key through the response button's existing action callback when the top window handles the key.
- The installed MoM spellbook defines response captions `1` through `4` in `Scenarios/mom/scen0000/english/gamedata/scen_str.txt` and declares those SLIC buttons in its spellbook scripts.

## Proposed behavior boundary

Each SLIC response button receives an action key only when its displayed label begins with a unique digit from 1 through 9. A label with a multi-digit number is not a binding. The topmost window routes the digit to that button's existing action callback; the keyboard layer does not infer a response from its position in a list or implement spell logic.

The source `SlicButton` has no separate numeric field; its localized response label is already the visible key binding (the installed spellbook uses labels `1` through `4`). Resolve the exact label centrally and do not add new SLIC syntax or persisted fields.

## Response lifecycle

1. Response creation assigns the visible single-digit binding to its button action key when the digit occurs on exactly one response.
   Every control initializes its action key to zero before optional LDL shortcuts or response bindings are applied; unnumbered buttons cannot inherit a recycled numeric key.
2. When SDL text input is inactive, SDL translates top-row and keypad digit keydown events to their ASCII digit values and passes them to `ui_HandleKeypress`; when text input is active, the existing `SDL_TEXTINPUT` route supplies the digit instead.
3. A topmost message border resolves to its owning message window; an unrelated top window retains input ownership. The resolved window routes the digit to its response buttons through `HandleKey`.
4. The response button dispatches through its existing action callback.
5. A duplicate or missing digit binding leaves the original keyboard route intact.
6. Any follow-up SLIC alertbox/messagebox assigns and handles its own response bindings.

## Integration contracts

| Existing element | Contract to reuse |
|---|---|
| `SlicButton::Callback()` | Executes the declared response body and segment context |
| `MessageModalResponseAction` | Preserves modal response completion and dismissal order |
| `MessageResponseAction` | Preserves standard response dispatch |
| `messageresponse_AssignNumberKeys` | Assigns unique displayed digit bindings to response button action keys |
| `aui_Control::HandleKey()` | Routes a matching key through the button's existing action callback |
| `SDLMessageHandler` | Converts physical SDL digit keydown events into the values understood by `ui_HandleKeypress` |
| `ui_HandleKeypress` | Preserves top-window precedence before global key mapping |
| `MessageModal::OwnsKeyboardSurface` | Recognizes the alertbox and its separately registered border windows; standard message borders are already child controls |

## Validation

Headless cases: unique input value, no match, duplicate values, response creates confirmation, ordinary text-field digit entry, mouse response regression, and repeated keydown. Check that each response body runs once and the follow-up screen remains available.

Test isolation: UIWalk must keep its owned windows outside the virtual desktop at fixed coordinates, release synthetic focus after input, and never reposition around the OS cursor or synthesize global input. Verify the launched executable SHA against the build; install and verify the tested Final-SDL executable at the normal shortcut target after the current game exits.

Capture contract: the incumbent SDL test hook accepts `capture:<BMP path>` and saves the composed primary SDL surface. UIWalk uses that output for offscreen capture and fails on a missing or stale file; desktop capture is not a substitute. This closes the observed stale-PrintWindow failure on fully offscreen windows.

Fixture setup: `message:<existing SLIC segment>` in that same hook may open a named scenario dialog for the visible player, with recipient and player context populated. This seeds the test menu only; numeric acceptance input still uses ordinary Windows keyboard messages and response buttons. Invalid names produce a logged refusal.

Mouse control: `response:<label>` locates the active alertbox's generated button by its displayed label and calls the incumbent `aui_Button::InjectPress`, the same control action used by UIWalk's existing named-button press command. This supplies the matched click control without moving the OS cursor; the keyboard case never uses this command.

