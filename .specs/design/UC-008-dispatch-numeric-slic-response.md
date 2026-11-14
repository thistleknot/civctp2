# Use Case: Dispatch a Numeric SLIC Response

## Overview

**Use Case ID:** UC-008  
**Use Case Name:** Dispatch a Numeric SLIC Response  
**Primary Actor:** CTP2 Keyboard Input Handler  
**Goal:** Resolve a digit to one active SLIC response and preserve ordinary response lifecycle behavior.  
**Trigger:** A keydown reaches the game while a SLIC response menu is the topmost input surface.  
**Status:** Draft  
**Type:** System

**Requirements:** [SM-REQ-001, SM-REQ-002, SM-REQ-003, SM-REQ-004, SM-REQ-005](../reqs/ctp2-slic-numeric-choice.rst)

## Preconditions

- The active topmost input surface is a SLIC response menu.
- The SLIC message remains valid in the message pool.

## Main Success Scenario

1. `ui_HandleKeypress` receives a digit keydown.
2. The handler confirms the active topmost surface is a SLIC response menu.
3. The handler resolves the digit against response numeric input values.
4. If exactly one response matches, the handler dispatches through that response's existing UI action.
5. The ordinary SLIC callback runs the response body once.
6. Any new confirmation menu becomes the active response surface and remains visible.

## Alternative Flows

### A1: No numeric response matches

**Trigger:** No active response has the pressed digit as its input value (step 3).  
**Flow:**

1. The handler declines the SLIC shortcut.
2. The original digit follows normal key handling. Use case ends.

### A2: Multiple numeric responses match

**Trigger:** Two or more active responses share the pressed numeric value (step 3).  
**Flow:**

1. The handler declines the ambiguous shortcut.
2. The message and response callbacks remain unchanged. Use case ends.

### A3: A non-SLIC window owns input

**Trigger:** The topmost input surface is not a SLIC response menu (step 2).  
**Flow:**

1. The SLIC shortcut resolver is not called.
2. The digit is delivered to the owning window. Use case ends.

### A4: The response becomes invalid before dispatch

**Trigger:** The active message is invalidated before its response callback runs (step 4).  
**Flow:**

1. The handler checks message validity at the dispatch boundary.
2. No SLIC body runs for an invalid message. Use case ends.

## Postconditions

### Success Postconditions

- At most one response callback runs for one matching keydown.
- A follow-up confirmation screen remains active.
- Mouse response behavior remains available.

### Failure Postconditions

- No response runs for an invalid, unmatched, or ambiguous message state.
- No response callback is invoked from spell-specific code.

## Business Rules

### BR-001: Numeric input values are response bindings; response array position is not a binding
### BR-002: A numeric binding must be unique in the active menu
### BR-003: Only the active SLIC response surface receives SLIC numeric input

