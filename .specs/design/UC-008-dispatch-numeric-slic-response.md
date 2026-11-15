# Use Case: Dispatch a Numeric SLIC Response

## Overview

**Use Case ID:** UC-008
**Use Case Name:** Dispatch a Numeric SLIC Response
**Primary Actor:** CTP2 Keyboard Input Handler
**Goal:** Resolve a digit to one active SLIC response and preserve the complete response-to-follow-up-screen lifecycle.
**Trigger:** A keydown reaches the game while a SLIC response menu is the topmost input surface.
**Status:** Draft
**Type:** System

**Requirements:** [SM-REQ-001, SM-REQ-002, SM-REQ-003, SM-REQ-004, SM-REQ-005, SM-REQ-006, SM-REQ-007, SM-REQ-009, SM-REQ-015](../reqs/ctp2-slic-numeric-choice.rst)

## Preconditions

- The active topmost input surface is a SLIC response menu.
- The SLIC message remains valid in the message pool.

## Main Success Scenario

1. SDL translates top-row and keypad digit events, including `0`, to the ASCII digit delivered to `ui_HandleKeypress`.
2. `ui_HandleKeypress` receives the digit through one input route.
3. The handler resolves a topmost alertbox border to its owning dialog; unrelated windows retain keyboard ownership.
4. The top window offers the digit to its controls; a uniquely matching SLIC response button uses the same click-completion activation path, including its SLIC UI trigger.
5. The ordinary SLIC callback runs the response body once.
6. If the response body closes the current menu and opens a detail or confirmation menu, the game completes the current response action and leaves the new menu active.
7. A later keydown is resolved against the new menu; it does not repeat the previous response.

## Alternative Flows

### A1: No numeric response matches

**Trigger:** No active response has the pressed digit as its input value (step 3).
**Flow:**

1. No response button has the digit action key.
2. The original digit follows normal key handling. Use case ends.

### A2: Multiple numeric responses match

**Trigger:** Two or more active responses share the pressed numeric value (step 3).
**Flow:**

1. No response button receives a duplicated digit action key.
2. The message and response callbacks remain unchanged. Use case ends.

### A3: A non-SLIC window owns input

**Trigger:** The topmost input surface is not a SLIC response menu (step 2).
**Flow:**

1. The SLIC response button is not the top-window keyboard target.
2. The digit is delivered through the owning control's normal path. Use case ends.

### A4: The response becomes invalid before dispatch

**Trigger:** The active message is invalidated before its response callback runs (step 4).
**Flow:**

1. The handler checks message validity at the dispatch boundary.
2. No SLIC body runs for an invalid message. Use case ends.

### A5: Zero is used to cancel

**Trigger:** The player presses `0` on a SLIC page with a numeric `0` response or an `X` close response (step 4).
**Flow:**

1. The handler assigns `0` to the visible numeric `0` response when present; otherwise it assigns `0` to a unique `X` close response.
2. The selected response follows its ordinary SLIC callback. Use case ends.

## Postconditions

### Success Postconditions

- At most one response callback runs for one matching keydown.
- A displayed `0` binding can activate its response, including Cancel.
- The response's declared next SLIC screen remains active after the old screen is dismissed.
- A separate later input is required to submit a spell command from that screen.
- Mouse response behavior remains available.

### Failure Postconditions

- No response runs for an invalid, unmatched, or ambiguous message state.
- No response callback is invoked from spell-specific code.

## Business Rules

### BR-001: Numeric input values are response bindings; response array position is not a binding
### BR-002: A numeric binding must be unique in the active menu
### BR-003: Only the active SLIC response surface receives SLIC numeric input

### BR-004: Response completion must not discard a follow-up SLIC screen
When a response body opens a new SLIC screen, finishing the prior screen's response lifecycle must leave the new screen active.

