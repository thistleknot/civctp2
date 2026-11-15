# Current interpretations

## The explicit feature request authorizes the isolated SLIC and J-route changes — 2026-11-15

- **Decision:** Update the numeric input source route and only the summon picker SLIC source, its required state declarations, localization rows, and governing specs. `J` resolves the active player's sphere and opens the existing matching spellbook hub; summon selection remains pending until `1`, while `0` returns to that hub.
- **Basis:** The user's active objective explicitly requires `J` to land on the spellbook page and the summon detail/cost/confirm path. The supplied operating contract also says to use the least-blocking interpretation and log decisions. The prior no-data-edit interpretation blocked directly requested behavior; it is superseded. Existing staged MoM edits remain untouched.
- **Decider:** AI, applying the user's task-specific objective to the standing role rule.
- **Scope:** Edit the numeric J handler in the active issue471 source checkout and only the MoM summon/state/localization/spec files required by the flow. Do not edit other scenario files, staged user changes, `userprofile.txt`, or publish/push anything.

## Cost and channel time follow the existing creature-rung rule — 2026-11-15

- **Decision:** Show and commit the existing effective cost formula `((45 + 30 * creature rung) * civilization percent) / 100`; show channel time equal to creature rung.
- **Basis:** `MomSummonOrderTick` already derives both debit and countdown from `MomSummonRungOf(selected unit)`. The detail page must predict the same values the existing processor will commit.
- **Decider:** AI, preserving established game economy while making it visible before confirmation.

## Superseded: no scenario-data edits for this feature — 2026-11-15

- **Prior decision:** Avoid editing `Scenarios\\mom` because the local role contract prohibited it.
- **Superseded by:** The task-specific user objective to implement the missing summon review/confirmation flow, plus the local instruction to choose the least-blocking interpretation.
- **Evidence:** Current `MomSummonPick_life_1` commits the creature immediately; Git history has no prior detail/confirm flow to restore.

## Number zero is a valid SLIC response binding — 2026-11-15

- **Decision:** Treat a displayed single digit from `0` through `9` as an eligible SLIC keyboard binding; preserve uniqueness and ignore multi-digit labels.
- **Basis:** The user specified `0` for cancel and `1` for confirm on the detail page. The current response mapper only accepted `1` through `9`.
- **Decider:** AI, applying the user's stated response values.
- **Open evidence:** The active summon picker script currently has no detail page or `0` response. Runtime confirmation of the full page sequence remains with the operator.
