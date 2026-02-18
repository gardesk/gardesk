-- gar default configuration
-- Copy to ~/.config/gar/init.lua to customize

-- Autostart applications (only run once per session)
-- gar.exec_once("random-bg cold")  -- Pick random wallpaper from a themed directory
-- garbg daemon is managed by systemd (garbg.service) with internal X11 retry
gar.exec_once("garbg set ~/Pictures/background/ --random")

-- Screen locker daemon
gar.exec_once("garlock daemon")

-- Clipboard manager daemon
gar.exec_once("garclip daemon --foreground")

-- System tray with quick settings panel
gar.exec_once("gartray daemon")

-- Polkit authentication agent (needed for power actions via D-Bus)
gar.exec_once("garcard daemon")

-- External fallback authentication agents (optional):
-- gar.exec_once("/usr/libexec/kf6/polkit-kde-authentication-agent-1")
-- gar.exec_once("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")

-- Compositor (garchomp or picom)
-- Use Mod+Shift+C to toggle between them
-- Setting "compositor" to "none" disables gar's auto picom management
gar.set("compositor", "garchomp")

-- Compositor toggle function
function toggle_compositor()
    -- Check if garchomp is running
    local handle = io.popen("pgrep -x garchomp")
    local result = handle:read("*a")
    handle:close()

    if result ~= "" then
        -- garchomp is running, switch to picom
        os.execute("pkill -x garchomp")
        os.execute("sleep 0.1 && picom --config ~/.config/gar/picom.conf &")
    else
        -- picom is running (or nothing), switch to garchomp
        os.execute("pkill -x picom")
        os.execute("sleep 0.1 && garchomp &")
    end
end

-- Uncomment the ones you want:
-- gar.exec_once("dunst")                      -- Notification daemon
-- gar.exec_once("nm-applet")                  -- NetworkManager tray icon
-- gar.exec_once("blueman-applet")             -- Bluetooth tray icon
-- gar.exec_once("xss-lock -- i3lock -c 000000")    -- Auto-lock on suspend

-- Appearance
gar.set("border_width", 2)
gar.set("border_color_focused", "#5294e2")
gar.set("border_color_unfocused", "#2d2d2d")
gar.set("gap_inner", 12)
gar.set("gap_outer", 16)

-- Visual Effects (picom compositor)
-- DISABLED: Using garchomp instead. Uncomment these to use picom.
-- gar auto-generates ~/.config/gar/picom.conf from these settings
-- Changes take effect on reload (Mod+Shift+R) - picom is signaled automatically
-- gar.set("corner_radius", 18)              -- 0 = square corners
-- gar.set("blur_enabled", true)
-- gar.set("blur_method", "dual_kawase")     -- "gaussian", "dual_kawase", "box"
-- gar.set("blur_strength", 5)               -- 1-20 for dual_kawase
-- gar.set("shadow_enabled", true)
-- gar.set("shadow_radius", 12)
-- gar.set("shadow_opacity", 0.75)
-- gar.set("shadow_offset_x", -7)
-- gar.set("shadow_offset_y", -7)
-- gar.set("opacity_focused", 0.94)
-- gar.set("opacity_unfocused", 0.6)         -- Set to 0.9 to dim unfocused windows
-- gar.set("fade_enabled", true)
-- gar.set("fade_delta", 3)

-- Visual Effects (garchomp compositor)
-- These settings are only loaded when garchomp reads the config
if garchomp then
    garchomp.set("blur_enabled", true)
    garchomp.set("blur_strength", 5)
    garchomp.set("shadow_enabled", true)
    garchomp.set("shadow_radius", 12)
    garchomp.set("shadow_offset_x", -7)
    garchomp.set("shadow_offset_y", -7)
    garchomp.set("shadow_opacity", 0.75)
    garchomp.set("corner_radius", 18)
    garchomp.set("fade_enabled", true)
    garchomp.set("fade_duration", 0.15)
    garchomp.set("vsync", "adaptive")

    -- garchomp animations
    garchomp.animate("window_open", {
        duration = 0.15,
        curve = "ease-out",
        animate = function(t, window)
            window:set_scale(0.95 + 0.05 * t, 0.95 + 0.05 * t)
            window:set_opacity(t)
        end
    })

    garchomp.animate("window_close", {
        duration = 0.1,
        curve = "ease-in",
        animate = function(t, window)
            local inv = 1 - t
            window:set_scale(0.95 + inv * 0.05, 0.95 + inv * 0.05)
            window:set_opacity(inv)
        end
    })

    -- garchomp per-window rules
    garchomp.rule({ class = "Alacritty" }, { blur_behind = true, opacity = 0.94 })
    garchomp.rule({ class = "kitty" }, { blur_behind = true, opacity = 0.94 })
    garchomp.rule({ class = "garterm" }, { blur_behind = true, opacity = 0.94 })
    garchomp.rule({ class = "mpv" }, { shadow_enabled = false, corner_radius = 0 })
end

-- Title bars (disabled by default)
-- gar.set("titlebar_enabled", true)
-- gar.set("titlebar_height", 20)
-- gar.set("titlebar_color_focused", "#3d3d3d")
-- gar.set("titlebar_color_unfocused", "#2d2d2d")
-- gar.set("titlebar_text_color", "#ffffff")

-- Border gradients (purple to blue theme)
-- direction options: "vertical", "horizontal", "diagonal"
gar.set("border_gradient_enabled", true)
gar.set("border_gradient_start_focused", "#9b59b6")    -- Purple
gar.set("border_gradient_end_focused", "#3498db")      -- Blue
gar.set("border_gradient_start_unfocused", "#4a235a")  -- Dark purple
gar.set("border_gradient_end_unfocused", "#1a5276")    -- Dark blue
gar.set("border_gradient_direction", "diagonal")

-- Animations (picom v12+)
-- open options: "slide-in", "fly-in", "appear", "none"
-- close options: "slide-out", "fly-out", "disappear", "none"
-- DISABLED: Using garchomp instead
-- gar.set("animation_open", "appear")
-- gar.set("animation_close", "disappear")
-- gar.set("animation_duration", 0.15)      -- seconds

-- Custom GLSL shader (picom, requires GLX backend)
-- Bundled shaders: ~/.config/gar/shaders/focused-glow.glsl, dim-unfocused.glsl
-- gar.set("picom_shader", "~/.config/gar/shaders/focused-glow.glsl")

-- Per-window picom rules
-- NOTE: When using rules, picom ignores old-style options (inactive-opacity, shadow-exclude, etc.)
-- Only enable rules if you want full control via rules-based config
-- Available rule options: corner_radius, opacity, shadow, blur_background, shader
-- Match syntax: class_g = 'ClassName', class_i = 'instance', name = 'title', window_type = 'type'
-- gar.picom_rule({
--     match = "class_g = 'Alacritty'",
--     blur_background = true,
--     opacity = 0.92,
-- })
-- gar.picom_rule({
--     match = "class_g = 'firefox'",
--     corner_radius = 8,
-- })

-- garbar status bar (native gar integration)
-- When this table is present, gar automatically spawns and manages garbar
gar.bar = {
    height = 32,
    position = "top",
    background = "#1a1a1a",
    foreground = "#ffffff",
    opacity = 1.0,
    fonts = {
        "JetBrainsMono Nerd Font:size=10",
        "Symbols Nerd Font:size=10",
    },
    padding = { left = 8, right = 16, top = 0, bottom = 0 },

    -- Module layout
    modules_left = { "workspaces", "window_title" },
    modules_center = {},
    modules_right = { "filesystem", "memory", "cpu", "battery", "wlan", "volume", "tray", "datetime", "quick_settings" },

    -- Module configurations
    modules = {
        workspaces = {
            font_size = 11,
            focused = {
                foreground = "#ffffff",
                background = "transparent",
                underline = { width = 2, color = "#33ccff" },
            },
            unfocused = {
                foreground = "#666666",
                background = "transparent",
            },
            urgent = {
                foreground = "#ffffff",
                background = "#ff5555",
            },
        },
        window_title = {
            max_length = 50,
            empty_text = "Desktop",
        },
        datetime = {
            format = " %a %b %d   %H:%M",
        },
        cpu = {
            format = " {usage}%",
        },
        memory = {
            format = " {percent}%",
        },
        battery = {
            device = "auto",
            format_charging = " {percent}%",
            format_discharging = " {percent}%",
            format_full = " Full",
        },
        -- Script modules (custom commands)
        script = {
        filesystem = {
            exec = [[df -h / | awk 'NR==2 {print " " $4}']],
            interval = 60,
        },
        wlan = {
            exec = [[
IFACE=$(ip -o link show | awk -F': ' '/wl/{print $2; exit}')
if [ -n "$IFACE" ] && [ -d "/sys/class/net/$IFACE" ]; then
  STATE=$(cat /sys/class/net/$IFACE/operstate 2>/dev/null)
  if [ "$STATE" = "up" ]; then
    ESSID=$(iwgetid -r 2>/dev/null || echo "")
    IP=$(ip -4 addr show $IFACE 2>/dev/null | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | head -1)
    if [ -n "$ESSID" ]; then
      echo " $ESSID $IP"
    else
      echo " connected"
    fi
  else
    echo " offline"
  fi
else
  echo " N/A"
fi
]],
            interval = 5,
        },
        volume = {
            exec = [[
if command -v pamixer >/dev/null 2>&1; then
  if pamixer --get-mute | grep -q true; then
    echo " muted"
  else
    VOL=$(pamixer --get-volume)
    echo " $VOL%"
  fi
elif command -v pactl >/dev/null 2>&1; then
  VOL=$(pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\d+%' | head -1)
  MUTE=$(pactl get-sink-mute @DEFAULT_SINK@ | grep -oP 'yes|no')
  if [ "$MUTE" = "yes" ]; then
    echo " muted"
  else
    echo " $VOL"
  fi
else
  echo " N/A"
fi
]],
            interval = 1,
        },
        },
    },
}

-- Behavior
gar.set("follow_window_on_move", true)  -- Follow window when using Mod+Shift+number

-- Mod key: "mod" = Super/Win, "alt" = Alt
-- Use "mod" for real X session, "alt" for nested testing (Xephyr)
local mod = "mod"

-- Terminal (fallback)
gar.bind(mod .. "+Return", function()
    gar.exec("garterm || alacritty || kitty || foot || xterm")
end)

-- garterm with fish shell (debug logging enabled)
gar.bind(mod .. "+shift+Return", function()
    gar.exec("RUST_BACKTRACE=1 RUST_LOG=debug garterm >/tmp/garterm_debug.log 2>&1")
end)

--------------------------------------------------------------------------------
-- GARTERM CONFIGURATION
--------------------------------------------------------------------------------
-- garterm reads this table for shell, font, colors, sessions, and keybinds

gar.terminal = {
    -- Default shell
    shell = "/usr/bin/fish",

    -- Font settings
    font = {
        family = "JetBrainsMono Nerd Font",
        size = 20.0,
    },

    -- Color scheme
    colors = {
        preset = "dracula",
    },

    -- Tab bar configuration
    tab_bar = {
        height = 24,                          -- Tab bar height in pixels
        position = "top",                     -- "top" or "bottom"
        show_single_tab = false,              -- Show tab bar even with one tab
        max_tab_width = 200,                  -- Maximum width per tab in pixels
        tab_padding = 16,                     -- Horizontal padding inside each tab
        shorten_paths = true,                 -- Shorten paths: ~/P/a/src style

        -- Colors as {R, G, B, A} with values 0.0 to 1.0
        background = {0.08, 0.08, 0.12, 1.0}, -- Tab bar background
        active_bg = {0.15, 0.15, 0.20, 1.0},  -- Active tab background
        inactive_bg = {0.10, 0.10, 0.14, 1.0},-- Inactive tab background
        active_fg = {1.0, 1.0, 1.0, 1.0},     -- Active tab text color
        inactive_fg = {0.7, 0.7, 0.7, 1.0},   -- Inactive tab text color
    },

    -- Session definitions (load with gartermctl load-session <name>)
    sessions = {
        -- Example development workspace
        -- ["my-project"] = {
        --     tabs = {
        --         {
        --             title = "Frontend",
        --             cwd = "~/projects/my-app",
        --             cmd = "npm run dev",
        --         },
        --         {
        --             title = "Backend",
        --             cwd = "~/projects/my-backend",
        --             cmd = "python manage.py runserver",
        --         },
        --         {
        --             title = "Editor",
        --             cwd = "~/projects/my-app",
        --             cmd = "nvim",
        --         },
        --     },
        -- },
    },

    -- Keybinds within garterm (Lua function callbacks)
    keybinds = {
        -- Quick session loading example
        -- ["alt+m"] = { action = "load_session", session = "my-project"},
    },
}

-- Close window
gar.bind(mod .. "+q", gar.close_window)

-- Reload config
gar.bind(mod .. "+shift+r", gar.reload)

-- Exit gar (return to display manager)
gar.bind(mod .. "+shift+e", gar.exit)

-- Focus navigation (arrow keys)
gar.bind(mod .. "+Left", gar.focus("left"))
gar.bind(mod .. "+Right", gar.focus("right"))
gar.bind(mod .. "+Up", gar.focus("up"))
gar.bind(mod .. "+Down", gar.focus("down"))

-- Focus navigation (vim keys)
gar.bind(mod .. "+h", gar.focus("left"))
gar.bind(mod .. "+l", gar.focus("right"))
gar.bind(mod .. "+k", gar.focus("up"))
gar.bind(mod .. "+j", gar.focus("down"))

-- Swap windows
gar.bind(mod .. "+shift+Left", gar.swap("left"))
gar.bind(mod .. "+shift+Right", gar.swap("right"))
gar.bind(mod .. "+shift+Up", gar.swap("up"))
gar.bind(mod .. "+shift+Down", gar.swap("down"))

gar.bind(mod .. "+shift+h", gar.swap("left"))
gar.bind(mod .. "+shift+l", gar.swap("right"))
gar.bind(mod .. "+shift+k", gar.swap("up"))
gar.bind(mod .. "+shift+j", gar.swap("down"))

-- Resize
gar.bind(mod .. "+ctrl+Left", gar.resize("left", 0.05))
gar.bind(mod .. "+ctrl+Right", gar.resize("right", 0.05))
gar.bind(mod .. "+ctrl+Up", gar.resize("up", 0.05))
gar.bind(mod .. "+ctrl+Down", gar.resize("down", 0.05))

gar.bind(mod .. "+ctrl+h", gar.resize("left", 0.05))
gar.bind(mod .. "+ctrl+l", gar.resize("right", 0.05))
gar.bind(mod .. "+ctrl+k", gar.resize("up", 0.05))
gar.bind(mod .. "+ctrl+j", gar.resize("down", 0.05))

-- Equalize splits
gar.bind(mod .. "+e", gar.equalize)

-- Toggle floating
gar.bind(mod .. "+f", gar.toggle_floating)

-- Toggle fullscreen
gar.bind(mod .. "+shift+f", gar.toggle_fullscreen)

-- Cycle through floating windows
gar.bind(mod .. "+grave", gar.cycle_floating)  -- Mod+` (backtick)

-- Workspaces
for i = 1, 9 do
    gar.bind(mod .. "+" .. i, gar.workspace(i))
    gar.bind(mod .. "+shift+" .. i, gar.move_to_workspace(i))
end
gar.bind(mod .. "+0", gar.workspace(10))
gar.bind(mod .. "+shift+0", gar.move_to_workspace(10))

-- Multi-monitor (comma/period = prev/next)
gar.bind(mod .. "+comma", gar.focus_monitor("prev"))
gar.bind(mod .. "+period", gar.focus_monitor("next"))
gar.bind(mod .. "+shift+comma", gar.move_to_monitor("prev"))
gar.bind(mod .. "+shift+period", gar.move_to_monitor("next"))

-- Workspace cycling
gar.bind(mod .. "+Tab", gar.workspace_next())
gar.bind(mod .. "+shift+Tab", gar.workspace_prev())

-- Launchers (garlaunch)
gar.bind(mod .. "+space", function()
    gar.exec("garlaunch --mode drun")
end)
gar.bind(mod .. "+shift+space", function()
    gar.exec("garlaunch --mode window")
end)
gar.bind(mod .. "+r", function()
    gar.exec("garlaunch --mode run")
end)

-- dmenu alternative (if garlaunch not available)
gar.bind(mod .. "+p", function()
    gar.exec("dmenu_run")
end)

-- Screenshot (requires scrot or maim)
gar.bind("Print", function()
    gar.exec("scrot -e 'mv $f ~/Pictures/' || maim ~/Pictures/screenshot-$(date +%s).png")
end)
gar.bind(mod .. "+Print", function()
    gar.exec("scrot -s -e 'mv $f ~/Pictures/' || maim -s ~/Pictures/screenshot-$(date +%s).png")
end)

-- Screenshot (garshot)
gar.bind("ctrl+shift+3", function()
    gar.exec("garshot select --annotate")  -- Region selection with annotation editor
end)
gar.bind("ctrl+shift+4", function()
    gar.exec("garshot select")  -- Interactive region selection with blur overlay
end)
gar.bind("ctrl+shift+5", function()
    gar.exec("garshot screen")  -- Full screen capture
end)
gar.bind("ctrl+shift+6", function()
    gar.exec("garshot window")  -- Active window capture
end)

-- Slideshow mode (Mod+Shift+P to avoid conflict with dmenu on Mod+P)
gar.bind(mod .. "+shift+p", function() gar.exec("garbg set ~/Pictures/background/ --random --interval 2m") end)

-- Lock screen (requires i3lock, swaylock, or slock)
gar.bind(mod .. "+Escape", function()
    gar.exec("i3lock -c 000000 || swaylock -c 000000 || slock")
end)

-- Lock screen with garlock (via daemon)
gar.bind(mod .. "+shift+q", function()
    gar.exec("garlock lock")
end)

-- Volume controls (requires pactl/pamixer)
gar.bind("XF86AudioRaiseVolume", function()
    gar.exec("pactl set-sink-volume @DEFAULT_SINK@ +5% || pamixer -i 5")
end)
gar.bind("XF86AudioLowerVolume", function()
    gar.exec("pactl set-sink-volume @DEFAULT_SINK@ -5% || pamixer -d 5")
end)
gar.bind("XF86AudioMute", function()
    gar.exec("pactl set-sink-mute @DEFAULT_SINK@ toggle || pamixer -t")
end)

-- Brightness controls (requires brightnessctl or light)
gar.bind("XF86MonBrightnessUp", function()
    gar.exec("brightnessctl set +10% || light -A 10")
end)
gar.bind("XF86MonBrightnessDown", function()
    gar.exec("brightnessctl set 10%- || light -U 10")
end)

-- Clipboard history (garclip)
gar.bind(mod .. "+shift+v", function()
    gar.exec("garclip-picker")
end)

-- Toggle compositor (garchomp <-> picom)
gar.bind(mod .. "+shift+c", toggle_compositor)
