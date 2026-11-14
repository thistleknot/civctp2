# SLIC Numeric Choice Selection

**Status:** Draft
**Decision:** [ADR-002](ctp2-slic-numeric-choice.decision.md)
**Requirements:** [SM-REQ-001–SM-REQ-005](../.specs/reqs/ctp2-slic-numeric-choice.rst)
**Scope:** Native executable behavior for player-facing SLIC response menus; scenario scripts remain responsible for the response body and any follow-up confirmation.

## User-visible contract

When the active SLIC response menu exposes a response with numeric input value `n`, shown on that response button, pressing the matching digit selects that response exactly as clicking its button would. The menu's response callback remains authoritative: keyboard activation invokes the same SLIC button body once and does not bypass, suppress, or auto-accept any follow-up confirmation screen.

Numeric values are response bindings, not decoration. The current SLIC interface carries the value in the response button label; a label is a binding only when it is exactly one digit from 1 through 9. The value is not inferred from screen position or list order. A digit with no unique matching response is not consumed as a SLIC choice and continues through ordinary input handling.

## Boundaries

- Applies to active SLIC alertbox and messagebox response menus, including the current MoM spellbook pages.
- Does not assign numeric shortcuts to ordinary engine dialogs or unrelated text fields.
- Does not change SLIC script behavior, spell cost checks, target checks, or confirmation logic.
- Does not activate a response when a numeric value is missing or duplicated.
- The first response activation may open another SLIC menu; a later keypress is evaluated against that new active menu only.

## Validation

Verify numeric choices 1, 2, and 3 each activate the matching SLIC response; an unmapped digit leaves the menu open; mouse activation still works; and a response that opens confirmation leaves that confirmation visible and independently actionable.

