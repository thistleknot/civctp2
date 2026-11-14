SLIC Numeric Choice Requirements
===============================

The executable behavior below derives from :doc:`../../specs/ctp2-slic-numeric-choice.spec` and :doc:`../../specs/ctp2-slic-numeric-choice.decision`.

.. req:: Activate the response matching a numeric input value
   :id: SM-REQ-001
   :status: open
   :tags: functional, slic, keyboard

   When the player presses a digit matching one unique numeric input value in the active SLIC response menu, the system shall activate that response through its ordinary response callback.

.. req:: Preserve the SLIC response result flow
   :id: SM-REQ-002
   :status: open
   :tags: functional, slic, callback

   When a numeric key activates a SLIC response, the system shall run the same response body once that mouse activation runs.

.. req:: Keep follow-up confirmation independent
   :id: SM-REQ-003
   :status: open
   :tags: functional, slic, confirmation

   When a SLIC response opens a confirmation menu, the system shall leave that menu visible for its own response.

.. req:: Ignore ambiguous and unmatched numeric bindings
   :id: SM-REQ-004
   :status: open
   :tags: safety, keyboard

   If the active SLIC menu has no matching numeric input value or has duplicate matching values, then the system shall leave the SLIC response unchanged and pass the digit to normal key handling.

.. req:: Restrict digit interception to SLIC response menus
   :id: SM-REQ-005
   :status: open
   :tags: compatibility, keyboard

   While a non-SLIC text field or unrelated window owns keyboard input, the system shall deliver digit keys through the existing input path.


