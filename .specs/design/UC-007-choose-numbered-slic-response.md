# Use Case: Choose a Numbered SLIC Response

## Overview

**Use Case ID:** UC-007
**Use Case Name:** Choose a Numbered SLIC Response
**Primary Actor:** CTP2 Player
**Goal:** Open the spellbook landing page with `J`, review a numbered spell, and decide whether to cast it.
**Trigger:** The player presses `J` during an active turn.
**Status:** Draft
**Type:** Business

**Requirements:** [SM-REQ-001, SM-REQ-002, SM-REQ-003, SM-REQ-004, SM-REQ-005, SM-REQ-006, SM-REQ-007, SM-REQ-009, SM-REQ-015, SM-REQ-016](../reqs/ctp2-slic-numeric-choice.rst)

## Preconditions

- The game is in an active turn and accepts player input.
- Each displayed number identifies one response on that page.

## Main Success Scenario

1. The player presses `J`.
2. The game displays the player's sphere-specific spellbook landing page, the same page opened by the Workings shortcut.
3. The player selects a spell category, opening More for Very Rare spells.
4. The game displays the available numbered spells.
5. The player clicks or presses a displayed number.
6. The game displays the selected spell's full description and mana cost without casting it.
7. The player presses `0` to cancel or `1` to cast.
8. If the player cancels, the game leaves mana unchanged and returns to the spellbook landing page.
9. If the player confirms, the game casts the selected spell through its existing spell effect.
10. The game applies only the response selected on the active page.

## Alternative Flows

### A1: No response has the pressed number

**Trigger:** The player presses a digit that has no matching response (step 3 or 5).
**Flow:**

1. The game leaves the SLIC response unchanged.
2. The key continues through normal handling.
3. Use case ends.

### A2: More than one response has the pressed number

**Trigger:** The active menu contains duplicate numeric response values (step 3).
**Flow:**

1. The game does not select an arbitrary response.
2. The SLIC menu remains available for mouse selection.
3. Use case ends.

### A3: A non-SLIC input control is active

**Trigger:** A text field or unrelated window owns keyboard input (step 3 or 5).
**Flow:**

1. The game delivers the digit to that control's existing keyboard path.
2. Use case ends.

## Postconditions

### Success Postconditions

- A unique matching SLIC response runs at most once.
- The first response's detail or confirmation screen is displayed before another choice is required.
- A spell runs only after the separate confirmation response.
- Canceling leaves the spell uncast.
- Mouse selection remains available.

### Failure Postconditions

- An unmatched or ambiguous digit does not run a SLIC response.
- Non-SLIC input behavior remains unchanged.

## Business Rules

### BR-001: Numeric input values are response bindings, not decoration or list positions
### BR-002: A numeric value must be unique in the active menu
### BR-003: A numbered response advances through its declared SLIC flow
The response's existing SLIC body determines the next screen and action; key input must preserve the same transition as mouse activation.

### BR-004: A detail screen is a separate decision
A player must make a new response on the detail or confirmation screen before a spell or summon command runs. `0` cancels and `1` confirms where those values are displayed.

### BR-005: A close button is the zero-key fallback
When a SLIC page displays `X` and has no explicit `0` response, pressing `0` activates `X`. A visible `0` response takes precedence.


