# Use Case: Route J to the Spellbook Landing Page

## Overview

**Use Case ID:** UC-010
**Use Case Name:** Route J to the Spellbook Landing Page
**Primary Actor:** CTP2 Keyboard Input Handler
**Goal:** Open the same spellbook landing page reached by the Workings shortcut.
**Trigger:** The player presses `J` during an active turn.
**Status:** Draft
**Type:** System

**Requirements:** [SM-REQ-015](../reqs/ctp2-slic-numeric-choice.rst)

## Preconditions

- The game has an active visible player.
- The MoM scenario has initialized that player's `MomSphere` value.

## Main Success Scenario

1. The game identifies the active player's sphere.
2. The game displays that sphere's spellbook landing page.

## Alternative Flows

### A1: MoM sphere data is unavailable

**Trigger:** The game cannot identify a supported sphere (step 1).
**Flow:**

1. The game opens the existing general magic menu if it is available.
2. The prior behavior is preserved. Use case ends.

## Postconditions

### Success Postconditions

- J and Workings open the same sphere-specific landing page in MoM.

### Failure Postconditions

- Other scenarios retain the existing general magic menu route when the sphere page is unavailable.

## Business Rules

### BR-001: Shared spellbook entry

J and Workings open the same sphere-specific landing page.
