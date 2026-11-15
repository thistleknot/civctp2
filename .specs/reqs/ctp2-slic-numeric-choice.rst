SLIC Numeric Choice Requirements
================================

The executable behavior below derives from ``specs/ctp2-slic-numeric-choice.spec.md`` and ``specs/ctp2-slic-numeric-choice.decision.md``.

.. req:: Activate the response matching a numeric input value
   :id: SM-REQ-001
   :status: open
   :tags: functional, slic, keyboard

   When the player presses a digit from 0 through 9 matching one unique numeric input value in the active SLIC response menu, the system shall activate that response through its ordinary response callback.

.. req:: Preserve the SLIC response result flow
   :id: SM-REQ-002
   :status: open
   :tags: functional, slic, callback

   When a numeric key activates a SLIC response, the system shall run the same response body once that mouse activation runs, including any next SLIC screen that body opens.

.. req:: Keep follow-up confirmation independent
   :id: SM-REQ-003
   :status: open
   :tags: functional, slic, confirmation

   When a SLIC response opens a detail or confirmation menu, the system shall display that next menu and wait for a separate player response.

.. req:: Ignore ambiguous and unmatched numeric bindings
   :id: SM-REQ-004
   :status: open
   :tags: safety, keyboard

   If the active SLIC menu has no matching numeric input value or has duplicate matching values, then the system shall leave the SLIC response unchanged and pass the digit to normal key handling.

.. req:: Route later digits to the newly active SLIC menu
   :id: SM-REQ-006
   :status: open
   :tags: functional, slic, keyboard, flow

   When a numbered response opens another SLIC menu, the system shall resolve a later digit against the newly active menu only.

.. req:: Preserve the declared SLIC response sequence
   :id: SM-REQ-007
   :status: open
   :tags: functional, slic, callback, flow

   When a numbered response body closes its current menu and opens a follow-up menu, the system shall preserve that follow-up through completion of the current response action.

.. req:: Restrict digit interception to SLIC response menus
   :id: SM-REQ-005
   :status: open
   :tags: compatibility, keyboard

   While a non-SLIC text field or unrelated window owns keyboard input, the system shall deliver digit keys through the existing input path.

.. req:: Report the summon channel time after confirmation
   :id: SM-REQ-008
   :status: open
   :tags: functional, slic, summon, result

   When the player confirms a summon from its detail screen, the system shall display the dynamic number of turns until the creature appears.

.. req:: Map zero to the SLIC close response
   :id: SM-REQ-009
   :status: open
   :tags: functional, slic, keyboard, confirmation

   When the active SLIC response menu contains a visible ``0`` response or, absent that, one visible ``X`` close response, the system shall bind ``0`` to the visible ``0`` response when present and otherwise to the unique ``X`` close response.

.. req:: Review a summon before placing its order
   :id: SM-REQ-010
   :status: open
   :tags: functional, slic, summon, detail

   When the player selects a creature from the summon picker, the system shall show its description, effective mana cost, and channel time without placing the summon order.

.. req:: Cancel a pending summon selection
   :id: SM-REQ-011
   :status: open
   :tags: functional, slic, summon, cancel

   When the player presses ``0`` on a summon detail page, the system shall discard the pending creature and leave mana and the committed summon order unchanged.

.. req:: Confirm a pending summon selection
   :id: SM-REQ-012
   :status: open
   :tags: functional, slic, summon, confirmation

   When the player presses ``1`` on a summon detail page, the system shall commit the pending creature through the existing summon order flow.

.. req:: Calculate summon detail cost and time from creature rung
   :id: SM-REQ-013
   :status: open
   :tags: functional, slic, summon, cost

   The system shall calculate effective summon mana cost as ``((45 + 30 * creature rung) * civilization percent) / 100``.

.. req:: Calculate summon channel time from creature rung
   :id: SM-REQ-014
   :status: open
   :tags: functional, slic, summon, channel

   The system shall calculate summon channel time as the selected creature's rung.



.. req:: Open the same spellbook landing page from J
   :id: SM-REQ-015
   :status: open
   :tags: functional, slic, spellbook, keyboard

   When the player presses ``J`` during an active turn, the system shall open the player's sphere-specific spellbook landing page, the same page opened by the Workings shortcut.

.. req:: Keep Very Rare spells and Magic Status reachable from the spellbook
   :id: SM-REQ-016
   :status: open
   :tags: functional, slic, spellbook, navigation

   When the player opens the More page from the spellbook landing page, the system shall show Very Rare spells, Magic Status, and Back options.
