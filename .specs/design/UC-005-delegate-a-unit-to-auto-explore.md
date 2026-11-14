# Use Case: Delegate a Unit to Auto-Explore

## Overview

**Use Case ID:** UC-005  
**Use Case Name:** Delegate a Unit to Auto-Explore  
**Primary Actor:** CTP2 Player  
**Goal:** Have a selected unit reveal useful territory while avoiding unsafe movement and responding to visible threats.  
**Trigger:** The player invokes Auto-Explore for the selected unit using its remappable key binding.  
**Status:** Draft  
**Type:** Business

**Requirements:** [AE-REQ-001, AE-REQ-002, AE-REQ-003, AE-REQ-004, AE-REQ-005, AE-REQ-006](../reqs/ctp2-auto-explore.rst)

## Preconditions

- The player has a selected unit that is eligible to move under its native movement rules.
- The executable has an Auto-Explore key binding, either the default lowercase `i` or the player's remapped key.

## Main Success Scenario

1. The player selects a unit that can move.
2. The player invokes Auto-Explore.
3. The game starts the unit's Auto-Explore order.
4. On the unit owner's turn, the unit moves toward safe territory that reveals the most unknown map area for its movement cost.
5. The game reevaluates the route after each movement segment and uses roads when they reduce the unit's native movement cost.
6. The unit continues while useful, safe territory remains reachable.
7. The game ends the order when no safe useful destination remains.

## Alternative Flows

### A1: A visible hostile approaches

**Trigger:** A hostile unit is visible within one normal movement allowance (step 4)  
**Flow:**

1. The game pauses exploration target selection.
2. The unit moves to the reachable safe tile with the highest applicable defense.
3. The use case continues at step 5.

### A2: No safe useful destination remains

**Trigger:** Every remaining destination is unreachable, unsafe, or no longer reveals useful unknown area (step 6)  
**Flow:**

1. The unit remains in place if no safe movement segment exists.
2. The game ends the Auto-Explore order without issuing an unsafe move.
3. Use case ends.

### A3: The player replaces the order

**Trigger:** The player issues another order to the unit (step 4 or 5)  
**Flow:**

1. The game stops Auto-Explore.
2. The replacement order remains active.
3. The use case ends.

### A4: The planned route becomes blocked

**Trigger:** Newly visible terrain or a unit blocks the next movement step (step 5)  
**Flow:**

1. The game replans from the unit's actual location using current owner-visible information.
2. If a safe route exists, the use case continues at step 4; otherwise, the game ends Auto-Explore.

## Postconditions

### Success Postconditions

- The unit has explored safe useful territory, adopted a defensive posture, or stopped because no safe useful destination remains.
- Any new order issued by the player has not been overwritten by Auto-Explore.

### Failure Postconditions

- The unit does not enter a tile the owner cannot safely enter or one occupied by a hostile unit.
- The player's other units and existing bindings remain unchanged.

## Business Rules

### BR-001: Owner knowledge only

The game uses only map and unit information currently available to the acting player.

### BR-002: High ground under threat

When a hostile is visible within the defined movement allowance, the unit favors the reachable safe terrain with the strongest applicable defense over continued exploration.

### BR-003: Player order takes precedence

An explicit replacement order cancels Auto-Explore and must not be replaced by its later replanning.
