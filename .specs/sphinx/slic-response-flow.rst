Numbered SLIC Spell Selection
=============================

.. include:: ../reqs/ctp2-slic-numeric-choice.rst

Business use case
-----------------

.. usecase:: Open the spellbook and choose a numbered spell
   :id: UC-007
   :status: draft
   :links: SM-REQ-001, SM-REQ-002, SM-REQ-003, SM-REQ-006, SM-REQ-007, SM-REQ-009, SM-REQ-015, SM-REQ-016
   :intent: Pressing J opens the same sphere-specific spellbook landing page as Workings; the player can inspect a numbered spell and separately cast or cancel it.
   :evidence: .specs/design/UC-007-choose-numbered-slic-response.md

   The player presses J and lands directly on the sphere-specific spellbook hub, the same hub opened by Workings. The player chooses a category, enters a displayed spell number, reads the full description and cost, then presses 0 to cancel or 1 to cast.

.. usecase:: Review and confirm a summon
   :id: UC-009
   :status: draft
   :links: SM-REQ-008, SM-REQ-010, SM-REQ-011, SM-REQ-012, SM-REQ-013, SM-REQ-014, SM-REQ-016
   :intent: The player inspects a creature's details, effective mana cost, and channel time before ordering it.
   :evidence: .specs/design/UC-009-review-summon-creature.md

   From the summon picker, the player selects a creature by click or number, reviews the details, then presses 1 to
   commit or 0 to cancel back to the sphere-specific spellbook landing page.

System use case
---------------

.. usecase:: Route J to the player's spellbook landing page
   :id: UC-010
   :status: draft
   :links: SM-REQ-015
   :intent: The keyboard handler opens the same sphere-specific spellbook hub reached by the Workings shortcut.
   :evidence: .specs/design/UC-010-route-j-to-spellbook.md; ctp2_code/ui/aui_ctp2/keypress.cpp

   The handler reads the current player's MomSphere array value, selects the corresponding MomSpellHub segment, and
   executes it; when the MoM sphere value is unavailable, the existing MagicMenu path remains the fallback.


.. usecase:: Dispatch a numbered SLIC response
   :id: UC-008
   :status: draft
   :links: SM-REQ-001, SM-REQ-002, SM-REQ-003, SM-REQ-004, SM-REQ-005, SM-REQ-006, SM-REQ-007, SM-REQ-009
   :intent: Deliver a numeric input through the active menu's existing response action and preserve its declared next-screen behavior.
   :evidence: .specs/design/UC-008-dispatch-numeric-slic-response.md; ctp2_code/ui/aui_ctp2/keypress.cpp:378-402; ctp2_code/ui/interface/messageactions.cpp:272-290

   The executable accepts top-row and keypad digits from 0 to 9, offers the digit to the
   active SLIC response controls, maps 0 to a unique X close response only if no literal 0
   is present, and runs the response callback once. When
   that response closes the current page and opens another page, the new page
   remains active and owns the next input.

Observed spellbook path
-----------------------

.. flow:: Open the sphere-specific spellbook landing page
   :id: FLOW_PAGE
   :status: required
   :links: SM-REQ-015
   :next: FLOW_DIGIT
   :evidence: ctp2_code/ui/aui_ctp2/keypress.cpp:423-433; Scenarios/mom/scen0000/default/gamedata/mom_spellbook_life.slc

   Required: pressing J must open the player’s `MomSpellHub_<sphere>` directly, the same landing page reached by the Workings shortcut.

.. flow:: Open More from the spellbook landing page
   :id: FLOW_MORE_PAGE
   :status: required
   :links: SM-REQ-016
   :next: FLOW_DIGIT
   :evidence: Scenarios/mom/scen0000/default/gamedata/mom_spellbook_life.slc; Scenarios/mom/scen0000/default/gamedata/mom_spells.slc

   More preserves the Very Rare spell category and opens Magic Status; Magic Status retains the summon and artifact actions. Back returns to the spellbook hub.

.. flow:: Enter a displayed number
   :id: FLOW_DIGIT
   :status: observed
   :links: SM-REQ-001, SM-REQ-005
   :next: FLOW_RESPONSE
   :evidence: ctp2_code/ctp/civ3_main.cpp:1976-1988, 2050-2060; ctp2_code/ui/aui_ctp2/keypress.cpp:378-402

   A top-row or keypad digit from 0 through 9 reaches its unique matching response once.

.. flow:: Run the matching SLIC response
   :id: FLOW_RESPONSE
   :status: observed
   :links: SM-REQ-002, SM-REQ-007
   :next: FLOW_DETAIL
   :evidence: ctp2_code/ui/interface/messageactions.cpp:280-289; ctp2_code/gs/slic/SlicButton.cpp:138-170

   The response body runs the same action as clicking its button.

.. flow:: Display the spell detail
   :id: FLOW_DETAIL
   :status: observed
   :links: SM-REQ-003, SM-REQ-006
   :next: FLOW_DECISION
   :evidence: Scenarios/mom/scen0000/default/gamedata/mom_spellbook_life.slc:468-479

   The detail screen shows the full text and mana cost, with `0` to cancel and `1` to confirm.

.. flow:: Wait for a separate detail-screen response
   :id: FLOW_DECISION
   :status: required
   :links: SM-REQ-003, SM-REQ-006
   :next: FLOW_RESULT
   :evidence: Scenarios/mom/scen0000/default/gamedata/mom_spellbook_life.slc:468-479

   A separate response on the detail screen commits the selection or cancels without spending mana.

.. flow:: Finish the selected response
   :id: FLOW_RESULT
   :status: required
   :links: SM-REQ-002, SM-REQ-007
   :evidence: .specs/design/UC-007-choose-numbered-slic-response.md

   After a summon is confirmed, the game reports the dynamic channel time before the creature appears.

Observed screenshot path and gap
--------------------------------

.. flow:: Open the Life rung-one summon picker
   :id: FLOW_SUMMON_PICKER
   :status: observed
   :links: SM-REQ-001
   :next: FLOW_SUMMON_CHOICE
   :evidence: Scenarios/mom/scen0000/default/gamedata/mom_summon.slc:452-456

   The reported screen lists Priest, Crusader, and Guardian Spirit as summon-unit choices.

.. flow:: Activate a summon-unit response
   :id: FLOW_SUMMON_CHOICE
   :status: required
   :links: SM-REQ-010, SM-REQ-013
   :next: FLOW_SUMMON_DETAIL
   :evidence: Scenarios/mom/scen0000/default/gamedata/mom_summon.slc:459-487

   Selecting a creature stores a pending choice, computes its effective cost and channel time from its rung, and opens its detail page without placing the summon order.

.. flow:: Review summon details
   :id: FLOW_SUMMON_DETAIL
   :status: required
   :links: SM-REQ-010, SM-REQ-013
   :next: FLOW_SUMMON_DECISION
   :evidence: .specs/design/ctp2-summon-selection-entity-model.md

   The detail page shows the selected creature description, effective mana cost, and expected channel turns, then waits for ``0`` cancel or ``1`` confirm.

.. flow:: Cancel or confirm summon review
   :id: FLOW_SUMMON_DECISION
   :status: required
   :links: SM-REQ-011, SM-REQ-012
   :next: FLOW_RESULT
   :evidence: .specs/design/UC-007-choose-numbered-slic-response.md

   ``0`` clears the pending selection and returns to the player’s ``MomSpellHub_<sphere>``; ``1`` transfers the pending unit into the existing summon order.

Flow view
---------

.. needflow::
   :engine: graphviz
   :config: layered
   :direction: right
   :filter: id.startswith('FLOW_')

Trace inventory
---------------

.. needtable::
   :columns: id, title, status, evidence
   :filter: id.startswith('SM-REQ-') or id.startswith('UC-') or id.startswith('FLOW_')

Scope note
----------

J opens the same sphere-specific ``MomSpellHub_<sphere>`` landing page reached by Workings. The separate magic status panel remains on its existing route.
When a page has no literal ``0`` choice, a unique ``X`` close response is the
keyboard cancel action for ``0``.
Current ``MomSummonPick_life_1`` source stores the selected unit directly as a
committed order and closes the picker. The required pending/detail/confirm
transition is specified above; numeric dispatch is not complete until the
click and key paths both preserve it.
