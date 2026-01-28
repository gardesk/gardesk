-- Garchomp Compositor Configuration
-- Location: ~/.config/garchomp/init.lua
-- Settings matched to picom.conf for feature parity

-- Shadow configuration (matching picom)
garchomp.set("shadow_enabled", true)
garchomp.set("shadow_radius", 12.0)
garchomp.set("shadow_opacity", 0.75)
garchomp.set("shadow_offset_x", -7.0)
garchomp.set("shadow_offset_y", -7.0)

-- Blur configuration (matching picom dual_kawase)
garchomp.set("blur_enabled", true)
garchomp.set("blur_strength", 5)

-- Window appearance (matching picom)
garchomp.set("corner_radius", 18.0)

-- Focus opacity (matching picom)
garchomp.set("opacity_focused", 0.94)
garchomp.set("opacity_unfocused", 0.60)

-- Fade animations (matching picom)
garchomp.set("fade_enabled", true)
garchomp.set("fade_in_duration", 0.15)
garchomp.set("fade_out_duration", 0.15)

-- HDR configuration (requires 10-bit display)
garchomp.set("hdr_enabled", false)
garchomp.set("hdr_peak_luminance", 1000.0)
garchomp.set("hdr_paper_white", 203.0)
garchomp.set("hdr_tonemap", "aces")

-- Window type rules (matching picom exclusions)
-- Dock windows: no shadow, no blur, no corners, fully opaque
garchomp.rule({ window_type = "dock" }, {
    shadow = false,
    blur_behind = false,
    corner_radius = 0,
    opacity = 1.0,
})

-- Desktop windows: no shadow, no blur, no corners
garchomp.rule({ window_type = "desktop" }, {
    shadow = false,
    blur_behind = false,
    corner_radius = 0,
})

-- Tooltips: no shadow, slight opacity
garchomp.rule({ window_type = "tooltip" }, {
    shadow = false,
    opacity = 0.95,
    blur_behind = false,
})

-- Menus: no shadow, slight opacity
garchomp.rule({ window_type = "menu" }, {
    shadow = false,
    opacity = 0.95,
    corner_radius = 0,
})

garchomp.rule({ window_type = "dropdown_menu" }, {
    shadow = false,
    opacity = 0.95,
    corner_radius = 0,
})

garchomp.rule({ window_type = "popup_menu" }, {
    shadow = false,
    opacity = 0.95,
    corner_radius = 0,
})

-- Fullscreen windows: no effects
garchomp.rule({ fullscreen = true }, {
    shadow = false,
    blur_behind = false,
    corner_radius = 0,
    opacity = 1.0,
})

-- Terminal emulators: enable blur behind for transparency
garchomp.rule({ class = "garterm" }, {
    blur_behind = true,
    opacity = 0.94,
})

garchomp.rule({ class = "Alacritty" }, {
    blur_behind = true,
    opacity = 0.94,
})

garchomp.rule({ class = "kitty" }, {
    blur_behind = true,
    opacity = 0.94,
})

-- Example animation callback (for future use)
-- garchomp.animate("window_open", {
--     duration = 0.15,
--     curve = "ease-out",
--     animate = function(t, window)
--         window:set_scale(0.9 + 0.1 * t, 0.9 + 0.1 * t)
--         window:set_opacity(t)
--     end
-- })
