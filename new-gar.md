┌────────────────┬───────────────────┬────────────────────────────────────────────────────────────────────────────┐
 │ Gap            │ What's Needed     │ Notes                                                                      │
 ├────────────────┼───────────────────┼────────────────────────────────────────────────────────────────────────────┤
 │ Image Viewer   │ garview (present) │ Exists as submodule; still needs full suite integration (installer/gears). │
 ├────────────────┼───────────────────┼────────────────────────────────────────────────────────────────────────────┤
 │ Session Dialog │ garsession        │ Logout/restart/shutdown/switch-user dialog. gardm handles login, but what  │
 │                │                   │ about exit?                                                                │
 ├────────────────┼───────────────────┼────────────────────────────────────────────────────────────────────────────┤
 │ Calculator     │ garcalc (present) │ Exists and installs; still needs full suite integration (website/gears).   │
 ├────────────────┼───────────────────┼────────────────────────────────────────────────────────────────────────────┤
 │ Display Config │ gardisplay        │ Exists as submodule; still needs installer/docs/gears integration.         │
 ├────────────────┼───────────────────┼────────────────────────────────────────────────────────────────────────────┤
 │ Text Editor    │ garedit           │ Simple editor (gedit/leafpad tier). Optional but nice.                     │
 ├────────────────┼───────────────────┼────────────────────────────────────────────────────────────────────────────┤
 │ PDF Viewer     │ garpdf            │ zathura exists, but native gar styling?                                    │
 ├────────────────┼───────────────────┼────────────────────────────────────────────────────────────────────────────┤
 │ Audio Mixer    │ garmixer          │ gartray has volume, but full mixer (pavucontrol replacement)?              │
 ├────────────────┼───────────────────┼────────────────────────────────────────────────────────────────────────────┤
 │ Privilege Auth │ garpolicy         │ Polkit auth agent for privileged desktop actions (network, power, mounts). │
 ├────────────────┼───────────────────┼────────────────────────────────────────────────────────────────────────────┤
 │ Desktop Portal │ garportal         │ XDG portal backend (screenshot/screencast/open-uri/file chooser).          │
 ├────────────────┼───────────────────┼────────────────────────────────────────────────────────────────────────────┤
 │ MIME Handler   │ garopen/garmime   │ xdg-open equivalent + default app/MIME association management.              │
 └────────────────┴───────────────────┴────────────────────────────────────────────────────────────────────────────┘

 ────────────────────────────────────────────────────────────────────────────────

 My Take: Next Gar Product?

 Tier 0 — Desktop plumbing (new additions):
 - garpolicy — Polkit agent; required for password prompts in privileged actions
 - garportal — XDG portal backend for screenshots, opens, and app integrations
 - garopen / garmime — MIME/default app resolver + open helper

 Tier 0.5 — Integration debt (already present):
 - garview — Present, but not yet fully wired into install/control-surface flow
 - garcalc — Present, but missing full cross-suite surfacing (site + gargears panel)
 - gardisplay — Present, but still missing installer/docs/gargears integration

 Tier 1 — Finish what's started:
 - gartop (directory exists) — High value, you'll use it constantly
 - garalert (directory exists) — Needed for other tools (garlock auth prompts, garfield confirmations, etc.)

 Tier 2 — Biggest bang for buck:
 - garsession — Logout dialog. Small but polishes the UX significantly

 Tier 3 — Nice to have:
 - garedit — Lightweight native text editor
 - garpdf — Native-styled PDF specialist (if garview scope should stay broad/light)
 - garmixer — Full audio graph/device/stream manager
