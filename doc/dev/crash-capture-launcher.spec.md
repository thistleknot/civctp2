# Crash-capture launcher source and dependency selection spec

## Behavioral layer

The crash-capture launcher selects a source executable, checks whether its imported runtime dependencies can be staged, overlays that executable and runtime into the installed game directory, and restores original files after exit.

## Requirements

- R1: When no `-SourceRoot` is supplied, the launcher shall select the current integration build directory containing the validated Debug-SDL executable.
- R2: When a source executable is selected, the dependency gate shall inspect that executable's actual imported DLL names rather than infer dependencies from its filename.
- R3: When an imported non-system dependency is available in the install directory, source overlay, or Windows system directories, the launcher shall allow that executable to launch.
- R4: When an imported dependency cannot be resolved from those locations, the launcher shall report the missing DLL and use the configured Release fallback when available.
- R5: The launcher shall stage the selected executable, matching symbol map, and runtime DLL overlay before each run, then restore the installed files after exit.
- R6: The launcher shall preserve the existing architecture preflight and UI-sheet checks.

## Acceptance checks

- The integration Debug-SDL binary's actual imports do not include `MSVCRTD.dll`; its three debug CRT sidecars are staged from the source directory.
- A missing actual imported DLL is reported as a blocker.
- An unimported DLL name does not block launch.
- `-NoRun` reports the selected executable and launch mode without staging or starting the game.
- The default source directory resolves to the integration build used for the MoM runtime validation; callers can still override it with `-SourceRoot`.
- The selected executable's matching `.map` file is staged when present, and the existing runtime overlay is restored after the process exits.

## Evidence and scope

On 2026-10-25 the installed launcher defaulted to `H:\Games\civctp2\ctp2_code\ctp` and required `MSVCRTD.dll` for every `ctp2-dbg.exe`. PE import inspection showed the validated integration Debug-SDL executable imports `MSVCP140D.dll`, `VCRUNTIME140D.dll`, and `ucrtbased.dll`, but not `MSVCRTD.dll`. The false missing-DLL result silently selected the older Release executable, which then exited with access violation `0xc0000005` in `ntdll.dll`.

## Closed

- Filename-based debug CRT dependency lists are rejected: the two available debug executables have different import sets, so the filename does not determine their runtime dependencies.

## Preconditions and failure modes

- The source directory must contain an x86 executable and all non-system DLLs needed by the overlay.
- Unreadable or malformed PE import tables block selection with a diagnostic; the launcher must not silently claim dependencies are satisfied.
- This change diagnoses launch selection. It does not identify the cause of the Release executable's access violation.
