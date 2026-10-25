---
description: 'Safe Gaia countdown checks when scenarios omit Gaia victory records'
import: []
---

***definitions***

- :GaiaRequirements: are the tower, mainframe, and satellite endgame records used to determine whether the Gaia countdown may start.
- :ScenarioEndgameRecords: are the records loaded from the active scenario's `EndGameObjects.txt`.

***implementation reqs***

- `GaiaController::CanStartCountdown` owns the check because it gates every countdown decision.
- The three required record indexes are initialized by `GaiaController::InitializeStatics` and may be absent in a scenario.
- `CanStartCountdown` must not dereference a record until it has verified that the record exists.
- `InitializeStatics` resets linked asset indexes on every scenario database initialization; missing optional Gaia records are not assertion failures.
- `CanBuildTowers` rejects a missing processing-tower asset before asking terrain construction logic to read it.

***test reqs***

- Validate with a scenario that has no Gaia records, one that has all three, and one that has only a subset.
- For the MoM scenario, start a new game and advance three turns through the UI harness.

***functional specs***

- The system shall prevent `CanStartCountdown` from dereferencing an absent Gaia record whenever any :GaiaRequirements: record is missing from :ScenarioEndgameRecords:.
  - Given a scenario with no Gaia records, when game initialization evaluates the countdown, then initialization continues without an access violation.
  - Given a scenario with only some Gaia records, when game initialization evaluates the countdown, then the method returns `false` without an access violation.
- The system shall preserve the existing `CanStartCountdown` thresholds whenever all :GaiaRequirements: records are present.
  - Given a scenario with all Gaia records, when the method evaluates the countdown, then its result matches the existing threshold checks.
- The system shall reset Gaia asset indexes on every scenario initialization, including transitions from a complete record set to an absent or partial record set.
  - Given stock data was initialized first, when MoM data replaces it, then missing tower, satellite, and mainframe assets retain no stock index.
- The system shall reject AI tower construction when the current scenario has no Gaia tower asset.
