┌────────────────┬───────────────────┬────────────────────────────────────────────────────────────────────────────┐
 │ Gap            │ What's Needed     │ Notes                                                                      │
 ├────────────────┼───────────────────┼────────────────────────────────────────────────────────────────────────────┤
 │ Image Viewer   │ garview           │ Every DE has one. feh works but doesn't match the aesthetic.               │
 ├────────────────┼───────────────────┼────────────────────────────────────────────────────────────────────────────┤
 │ Session Dialog │ garsession        │ Logout/restart/shutdown/switch-user dialog. gardm handles login, but what  │
 │                │                   │ about exit?                                                                │
 ├────────────────┼───────────────────┼────────────────────────────────────────────────────────────────────────────┤
 │ Calculator     │ garcalc           │ Simple utility. Low effort, high completeness.                             │
 ├────────────────┼───────────────────┼────────────────────────────────────────────────────────────────────────────┤
 │ Display Config │ garmon /          │ Monitor arrangement, resolution, refresh rate. arandr alternative.         │
 │                │ gardisplay        │                                                                            │
 ├────────────────┼───────────────────┼────────────────────────────────────────────────────────────────────────────┤
 │ Text Editor    │ garedit           │ Simple editor (gedit/leafpad tier). Optional but nice.                     │
 ├────────────────┼───────────────────┼────────────────────────────────────────────────────────────────────────────┤
 │ PDF Viewer     │ garpdf            │ zathura exists, but native gar styling?                                    │
 ├────────────────┼───────────────────┼────────────────────────────────────────────────────────────────────────────┤
 │ Audio Mixer    │ garmixer          │ gartray has volume, but full mixer (pavucontrol replacement)?              │
 └────────────────┴───────────────────┴────────────────────────────────────────────────────────────────────────────┘

 ────────────────────────────────────────────────────────────────────────────────

 My Take: Next Gar Product?

 Tier 1 — Finish what's started:
 - gartop (directory exists) — High value, you'll use it constantly
 - garalert (directory exists) — Needed for other tools (garlock auth prompts, garfield confirmations, etc.)

 Tier 2 — Biggest bang for buck:
 - garview — Image viewer. Simple scope, immediate utility, makes garshot → garview a natural flow
 - garsession — Logout dialog. Small but polishes the UX significantly

 Tier 3 — Nice to have:
 - garcalc — Weekend project, checks a box
 - garmon — Display config. More complex but fills a real gap
