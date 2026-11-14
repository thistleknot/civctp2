#include "ctp2_config.h"
#include "c3.h"

#ifdef __AUI_USE_SDL__

#include "aui_ui.h"
#include "aui_uniqueid.h"
#include "aui_sdl.h"

#include <windows.h>        // WM_COPYDATA / COPYDATASTRUCT
#include "SlicEngine.h"     // g_slicEngine->RunUITriggers (headless UI-trigger inject)
#include "aui_ldl.h"        // aui_Ldl::GetObject (headless button-press inject)
#include "aui_button.h"     // aui_Button::InjectPress
#include "aui_listbox.h"    // aui_ListBox::SelectItem (headless list selection)

SDL_Surface *aui_SDL::m_lpdd = 0;
uint32 aui_SDL::m_SDLClassId = aui_UniqueId();
sint32 aui_SDL::m_SDLRefCount = 0;

// SKIP_SDL2_EVENT_ISSUES: TODO: handle SDL2 new keyboard-events especially for unicode characters:
//    SDL_TEXTEDITING,            /**< Keyboard text editing (composition) */
//    SDL_TEXTINPUT,              /**< Keyboard text input */
//    SDL_KEYMAPCHANGED           /**< Keymap changed due to a system event such as an
//                                     input language or keyboard layout change.
//                                */
// Headless UI-trigger injection (MoM 2026-07-18, v4 -- the mechanism that
// actually works for the SDL build). In an __AUI_USE_SDL__ exe SDL owns the
// Win32 WindowProc (the game's own WndProc in civ3_main.cpp is DEAD -- wired
// only in the DirectX build). SDL's SetWindowsMessageHook fires from SDL's
// PeekMessage PUMP loop (the header: "run before TranslateMessage()"), so it
// only sees POSTED messages -- NOT SendMessage'd ones, which is why a
// WM_COPYDATA (which must be sent, not posted) never reached it.
//
// So: an external tool writes the LDL control path to k_INJECT_FILE, then
// PostMessage(hwnd, k_INJECT_UITRIGGER_MSG, 0, 0). The posted message flows
// through SDL's pump -> this hook reads the file and calls RunUITriggers
// (enqueue-only; the main-loop ProcessUITriggers drains it). Fires the SLIC UI
// trigger exactly as a real left-click would -- no cursor, no coordinates.
#define k_INJECT_UITRIGGER_MSG	(0x8000 + 100)	// WM_APP+100, posted
#define k_INJECT_FILE			"H:\\mom_inject.txt"

void MoM_WindowsMessageHook(void * userdata, void * hWnd,
                            unsigned int message, Uint64 wParam, Sint64 lParam)
{
	if (message == k_INJECT_UITRIGGER_MSG)
	{
		FILE * f = fopen(k_INJECT_FILE, "rb");
		if (f)
		{
			char nameBuf[512];
			size_t n = fread(nameBuf, 1, sizeof(nameBuf) - 1, f);
			while (n > 0 && (nameBuf[n-1] == '\n' || nameBuf[n-1] == '\r'
			                 || nameBuf[n-1] == ' '))
				n--;
			nameBuf[n] = 0;
			FILE * dbg = fopen("H:\\mom_hook.log", "a");

			if (strncmp(nameBuf, "press:", 6) == 0)
			{
				// Direct button press: works at the main menus, where the
				// buttons are wired to C++ callbacks (SetActionFuncAndCookie),
				// not SLIC uitriggers. Path is the full LDL block name,
				// e.g. press:InitPlayWindow.NewGameButton
				const char * path = nameBuf + 6;
				aui_Button * b = (aui_Button *)aui_Ldl::GetObject(path);
				if (dbg) { fprintf(dbg, "INJECT press '%s' -> obj=%p\n", path, (void*)b); fclose(dbg); dbg = NULL; }
				if (b)
				{
					b->InjectPress();
					dbg = fopen("H:\\mom_hook.log", "a");
					if (dbg) { fprintf(dbg, "INJECT press returned OK\n"); fclose(dbg); dbg = NULL; }
				}
			}
			else if (strncmp(nameBuf, "select:", 7) == 0)
			{
				// Headless list selection: "select:<ldl path>,<index>".
				// CTP2_LISTBOX is declared `atomic true`, so its rows and its
				// scrollbar are NOT separately addressable by LDL path, and aui
				// polls GetCursorPos so PostMessage clicks never reach them
				// (measured: 0/36 grid clicks registered). Selecting by index
				// sidesteps both -- no coordinates, no scrolling required.
				// e.g. select:ScenarioWindow.AvailableListBox,3
				char * arg   = nameBuf + 7;
				char * comma = strrchr(arg, ',');
				sint32 idx   = comma ? atoi(comma + 1) : -1;
				if (comma) *comma = 0;
				aui_ListBox * lb = comma
					? (aui_ListBox *)aui_Ldl::GetObject(arg) : NULL;
				// BOUNDS GUARD: aui_ListBox::SelectItem does NOT range-check.
				// An out-of-range index crashes the game outright (measured:
				// idx=4 on a 4-item list -> 0xC0000005). Log and no-op instead,
				// so a probe can never kill the process.
				sint32 count = lb ? lb->NumItems() : 0;
				if (dbg) { fprintf(dbg, "INJECT select '%s' idx=%d -> obj=%p count=%d\n", arg, idx, (void*)lb, count); fclose(dbg); dbg = NULL; }
				if (lb && (idx < 0 || idx >= count))
				{
					dbg = fopen("H:\\mom_hook.log", "a");
					if (dbg) { fprintf(dbg, "INJECT select REFUSED: idx %d out of range [0,%d)\n", idx, count); fclose(dbg); dbg = NULL; }
				}
				else if (lb && idx >= 0)
				{
					lb->SelectItem(idx);
					dbg = fopen("H:\\mom_hook.log", "a");
					if (dbg) { fprintf(dbg, "INJECT select returned OK\n"); fclose(dbg); dbg = NULL; }
				}
			}
			else if (g_slicEngine)
			{
				// SLIC uitrigger path (in-game controls, e.g.
				// ControlPanelWindow.ControlPanel.ShortcutPad.MagicButton)
				if (dbg) { fprintf(dbg, "INJECT name='%s' -> RunUITriggers...\n", nameBuf); fclose(dbg); dbg = NULL; }
				g_slicEngine->RunUITriggers(nameBuf);
				dbg = fopen("H:\\mom_hook.log", "a");
				if (dbg) { fprintf(dbg, "INJECT RunUITriggers returned OK\n"); fclose(dbg); dbg = NULL; }
			}
			if (dbg) fclose(dbg);
		}
		if (f) fclose(f);
	}
}

int FilterEvents(void* userData, SDL_Event *event)
{
	switch(event->type)
	{
		// Quit event
		case SDL_QUIT:
		// Keyboard events
		case SDL_KEYDOWN:
		case SDL_KEYUP:
		case SDL_TEXTINPUT:
		// Mouse events
		case SDL_MOUSEMOTION:
		case SDL_MOUSEBUTTONDOWN:
		case SDL_MOUSEBUTTONUP:
		case SDL_MOUSEWHEEL:
		// Window event
		case SDL_WINDOWEVENT:
			return 1;
		default:
			return 0;
	}
}

AUI_ERRCODE aui_SDL::InitCommon(BOOL useExclusiveMode)
{
	m_exclusiveMode = useExclusiveMode;

//	SDL Init is done in CivApp::InitializeApp
/*	int rc = SDL_Init(SDL_INIT_VIDEO | SDL_INIT_EVENTTHREAD |
	                  SDL_INIT_AUDIO | SDL_INIT_TIMER);

	if (0 != rc) {
		fprintf(stderr, "SDL_Init failed: %s\n", SDL_GetError());
		return AUI_ERRCODE_CREATEFAILED;
	}
*/

	SDL_SetEventFilter(FilterEvents, NULL);
	SDL_SetWindowsMessageHook(MoM_WindowsMessageHook, NULL);

	return AUI_ERRCODE_OK;
}

aui_SDL::~aui_SDL()
{
	if (! --m_SDLRefCount) {
		SDL_Quit();
		m_lpdd = 0;
	}
}

#endif
