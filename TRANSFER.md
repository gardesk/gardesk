# Gardesk Transfer Notes

## Current Sprint: gartray Quick Settings Panel

### Completed
- [x] Basic quick settings popup panel with Cairo rendering
- [x] Volume slider with PipeWire/wpctl integration
- [x] WiFi toggle button with NetworkManager D-Bus
- [x] Bluetooth toggle button (BlueZ D-Bus, no hardware on dev machine)
- [x] DND toggle with dunst integration
- [x] Power actions (shutdown, reboot, hibernate)
- [x] Expandable WiFi network picker list
- [x] Hold-to-toggle WiFi/Bluetooth power (500ms threshold, fires while holding)
- [x] "Scanning for networks..." loading state before blocking scan
- [x] Scrollable WiFi list (max 5 visible, scroll wheel support)
- [x] Panel opens instantly (removed blocking scan at open)
- [x] Stale socket cleanup on daemon startup
- [x] Socket connectivity check in garbar's is_gartray_running()

### In Progress / Known Issues
- Panel height calculation may need tuning for edge cases
- Bluetooth device list could use same scrolling treatment
- No password entry UI for secured WiFi networks (relies on saved credentials)

### Architecture Notes
- gartray: system tray + quick settings panel daemon
- garbar: status bar with quick_settings module that triggers gartray via IPC
- IPC: Unix socket at `/run/user/$UID/gartray.sock`, JSON protocol
- After relog, must restart dev versions (system versions auto-start via gar)

### Dev Workflow
```bash
# Kill system versions, start dev versions
pkill -9 garbar gartray
DISPLAY=:$N /path/to/gardesk/garbar/target/debug/garbar daemon &
DISPLAY=:$N /path/to/gardesk/gartray/target/debug/gartray daemon &

# Build
cd gartray && nix develop --command cargo build

# Logs
tail -f /tmp/gartray.log
tail -f /tmp/garbar-dev.log
```

## Roadmap / Future Sprints

### gartray
- [ ] Bluetooth device picker with scrolling
- [ ] WiFi password entry dialog for new networks
- [ ] Battery percentage display (module exists, needs UI)
- [ ] Brightness slider (module exists, no backlight on desktop)
- [ ] Animated spinner for scanning state
- [ ] Click network to connect (works for saved networks)

### garbar
- [ ] System tray icon rendering improvements
- [ ] Module reload without restart

### gar (window manager)
- [ ] Pointer grab issues being worked on separately

## Recent Commits

### gartray
- `a1d2cf7` add scrollable WiFi network list with max 5 visible
- `5fec280` remove blocking scan at panel open, show scanning state before WiFi scan
- `1570387` Fire hold action while holding, add scanning state with delay
- `4564e69` Add hold-to-toggle power for WiFi/Bluetooth buttons

### garbar
- `0410c2b` add QuickSettingsConfig to modules config
- `fcd8dc8` Add socket connectivity check in is_gartray_running
