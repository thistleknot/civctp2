# Windowed resolution contract

## CURRENT

Purpose: permit bounded background testing at the requested 1024x768 without
changing the user's primary display or depending on its orientation.

## Requirements

- While SDL windowed mode is enabled, when the profile requests a width of at least 800 and a height of at least 600, the engine MUST use that window size independently of fullscreen display modes.
- While fullscreen mode is enabled, the engine MUST retain display-mode validation.
- If a profile window size is below the UI minimum, the engine MUST retain the existing fallback selection.
- When UIWalk launches a windowed run, the harness MUST verify its actual client size against the requested size before driving UI steps.
- If the actual client size differs, the harness MUST stop the run.

## Acceptance

- Given windowed 1024x768 and a portrait primary, when startup finishes, then the client is 1024x768 and the desktop orientation is unchanged.
- Given windowed 800x600, when selecting the initial window size, then 800x600 is accepted.
- Given fullscreen and an unlisted mode, when selecting the initial size, then the existing display-mode fallback remains in use.

Source owners: `ctp2_code/ctp/display.cpp`; the incumbent UIWalk profile and geometry checks.
