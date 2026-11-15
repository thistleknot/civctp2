# Use Case: Review and Confirm a Summon

## Overview

**Use Case ID:** UC-009
**Use Case Name:** Review and Confirm a Summon
**Primary Actor:** CTP2 Player
**Goal:** Inspect a creature's details, mana cost, and channel time before ordering it.
**Trigger:** The player opens Magic Status from the spellbook More page and selects Summon Creature.
**Status:** Draft
**Type:** Business

**Requirements:** [SM-REQ-008, SM-REQ-010, SM-REQ-011, SM-REQ-012, SM-REQ-013, SM-REQ-014, SM-REQ-016](../reqs/ctp2-slic-numeric-choice.rst)

## Preconditions

- A summon picker for the player's sphere is open.
- The selected creature is available at the player's current sphere rung.

## Main Success Scenario

1. The player selects a creature by clicking its numbered response or pressing that number.
2. The game shows the creature's combat summary, effective mana cost, and channel time without committing an order.
3. The player presses `1` to confirm.
4. The game commits the selected creature to the existing summon order flow.
5. When order processing begins, the game reports the dynamic turns remaining until arrival.

## Alternative Flows

### A1: Cancel summon review

**Trigger:** The player presses `0` on the creature detail page (step 2).
**Flow:**

1. The game clears the pending creature without changing mana or the committed order.
2. The game returns to the player's sphere-specific spellbook landing page. Use case ends.

### A2: Summoning is already in progress

**Trigger:** A summon is preparing when the player selects a creature (step 1) or confirms it (step 3).
**Flow:**

1. The game reports that the existing summon must finish.
2. The game creates no new order. Use case ends.

### A3: Insufficient mana

**Trigger:** The player cannot afford the selected creature (step 1 or 3).
**Flow:**

1. The game reports insufficient mana.
2. The game creates no pending or committed order. Use case ends.

## Postconditions

### Success Postconditions

- The selected summon is committed and the player is told the expected channel time.

### Failure Postconditions

- Cancellation and failed eligibility leave mana and the committed summon order unchanged.

## Business Rules

### BR-001: Review precedes commitment

Selecting a creature creates a pending selection; `1` alone commits it.

### BR-002: Cost follows creature rung

Effective cost is `((45 + 30 * creature rung) * civilization percent) / 100`.

### BR-003: Channel time follows creature rung

Channel time equals the selected creature's rung.
