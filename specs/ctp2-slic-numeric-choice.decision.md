# ADR-002: Numeric SLIC response bindings

**Status:** Proposed
**Date:** 2026-11-14

## Context

The executable already renders SLIC responses as buttons and dispatches them through `SlicButton::Callback`. The spellbook presents numeric response captions, but those captions must select the corresponding response when typed. A response may display another SLIC confirmation; keyboard activation must retain the script's existing callback flow.

## Decision

Use the response button's exact one-digit label (1–9) as its numeric input value and keyboard binding. Dispatch a matching digit through the same response activation path as a mouse click, once per keydown. Limit interception to the active SLIC response menu; let unmatched digits and digits in unrelated controls follow existing input handling.

## Consequences

- Selection follows the response's declared input value rather than its visual order.
- Mouse behavior and SLIC command bodies stay authoritative.
- Duplicate numeric bindings are ambiguous and must not select arbitrarily.
- The current C++ `SlicButton` exposes a localized name but has no separate numeric field. Use that label as the input value; do not add SLIC syntax or persistent message fields. Duplicate or non-digit labels are not bindings.

## AI-Context

- Constraints: preserve mouse activation; preserve confirmation screens; never intercept digits from unrelated text input; dispatch exactly once.
- Patterns: reuse the active message's SLIC response callback path.
- Anti-patterns: infer bindings from list order; call spell code directly from keypress handling; bypass confirmation flow.
- Verification commands: targeted numeric response harness; existing SLIC/alertbox headless scenarios; Debug-SDL build.

