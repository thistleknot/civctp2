# Use Case: Choose a Numbered SLIC Response

## Overview

**Use Case ID:** UC-007  
**Use Case Name:** Choose a Numbered SLIC Response  
**Primary Actor:** CTP2 Player  
**Goal:** Submit a numbered SLIC menu choice from the keyboard.  
**Trigger:** The player presses the digit shown as the response's input value.  
**Status:** Draft  
**Type:** Business

**Requirements:** [SM-REQ-001, SM-REQ-002, SM-REQ-003, SM-REQ-004, SM-REQ-005](../reqs/ctp2-slic-numeric-choice.rst)

## Preconditions

- A SLIC alertbox or message response menu is the active keyboard target.
- At least one response may carry a numeric input value.

## Main Success Scenario

1. The player opens a SLIC menu.
2. The menu displays numbered responses.
3. The player presses the number assigned to one response.
4. The game runs that response as if the player clicked its button.
5. If the response opens a confirmation menu, the player sees that menu and may click or use its own response binding.

## Alternative Flows

### A1: No response has the pressed number

**Trigger:** The player presses a digit that has no matching response (step 3).  
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

**Trigger:** A text field or unrelated window owns keyboard input (step 3).  
**Flow:**

1. The game delivers the digit to that control's existing keyboard path.
2. Use case ends.

## Postconditions

### Success Postconditions

- A unique matching SLIC response runs at most once.
- A follow-up confirmation opened by the response remains active.
- Mouse selection remains available.

### Failure Postconditions

- An unmatched or ambiguous digit does not run a SLIC response.
- Non-SLIC input behavior remains unchanged.

## Business Rules

### BR-001: Numeric input values are response bindings, not decoration or list positions
### BR-002: A numeric value must be unique in the active menu
### BR-003: The response's existing callback owns any follow-up confirmation

