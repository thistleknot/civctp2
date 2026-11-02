# Unit runtime modifier initialization spec

## Behavioral layer

`UnitData::Create` establishes the baseline runtime stats for a newly created unit. The MoM runtime modifiers must be initialized before any calculation reads them.

## Requirements

- R1: When a new unit is created, the system shall initialize all four MoM runtime modifiers to zero before calculating derived stats.
- R2: When a new unit's hit points are calculated, the system shall include the database maximum and existing owner, wonder, and feat bonuses with a zero initial MoM HP modifier.
- R3: When a new unit's movement is calculated, the system shall include database movement and existing engine adjustments with a zero initial MoM movement modifier.
- R4: When gameplay later applies a MoM modifier, the system shall include that modifier through the existing calculation path.

## Acceptance checks

- A newly created unit with database max HP 10 receives HP 10 when no existing bonuses apply.
- A newly created unit with database max HP 20 receives HP 20 when no existing bonuses apply.
- A newly created unit with database max HP 35 receives HP 35 when no existing bonuses apply.
- A newly created unit's movement equals its database movement before any spell movement modifier is applied.
- Existing nonzero owner/wonder/feat HP bonuses and later explicit spell modifiers continue to contribute through their existing calculation paths.

## Evidence and scope

The prior MoM debug run logged two combat units at `1717986938 HP` and stopped responding during combat at game turn 38. In `UnitData.cpp`, `UnitData::Create` currently calculates HP and movement before zeroing `m_hpMaxMod` and `m_moveMod`; `CalculateTotalHP` and `CalculateTotalMovePoints` each read those fields. The ordering is a falsifiable candidate cause. The change must not alter unit database records or MoM CSV data.

## Confirmation

Build the Debug-SDL executable, start a fresh MoM game, verify new-unit HP and movement are finite and match database stats, then advance with date-change checks through the previous turn-38 failure point. A source-order check alone does not confirm runtime behavior.
