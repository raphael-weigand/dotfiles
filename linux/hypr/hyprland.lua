-- T2 MacBook Pro: Lua port of hyprland.conf.
-- Previous files are preserved in backup-before-lua-20261102/.

-- Keep the verified startup fix: the AMD phantom output crashes framebuffer
-- allocation before lid-display.sh can dynamically disable it.
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })
hl.monitor({ output = "eDP-2", disabled = true })

hl.config({
    input = {
        kb_layout = "de",
        kb_options = "caps:escape",
        follow_mouse = 0,
        repeat_delay = 200,
        repeat_rate = 65,
        touchpad = { disable_while_typing = true, natural_scroll = true },
    },
    general = {
        gaps_in = 5,
        gaps_out = 10,
        border_size = 2,
        col = { active_border = "rgb(ffdd33)", inactive_border = "rgb(282828)" },
        layout = "dwindle",
    },
    decoration = {
        rounding = 8,
        -- These are the final values from the two old decoration blocks.
        active_opacity = 0.92,
        inactive_opacity = 0.86,
        fullscreen_opacity = 1.0,
        shadow = { enabled = true, range = 12, render_power = 3, color = "rgba(00000088)" },
        blur = { enabled = true, size = 8, passes = 2, popups = true },
    },
    animations = { enabled = true },
    cursor = { hide_on_key_press = true, inactive_timeout = 3 },
})

-- MX Keys Mini custom XKB remains disabled, as in the previous configuration.
-- hl.device({ name = "logitech-mx-keys-mini", kb_file = "~/.config/hypr/xkb/mxkeys.xkb" })

hl.window_rule({
    name = "localsend-overlay",
    match = { class = [[^org\.localsend\.localsend_app$]] },
    float = true,
    center = true,
    size = "900 650",
})
hl.layer_rule({
    name = "quickshell-blur",
    match = { namespace = "quickshell" },
    blur = true,
    ignore_alpha = 0.2,
})

for _, leaf in ipairs({ "windows", "windowsOut", "fade" }) do
    hl.animation({ leaf = leaf, enabled = true, speed = 2, bezier = "default" })
end
hl.animation({ leaf = "workspaces", enabled = false })

hl.bind("switch:on:Lid Switch", hl.dsp.exec_cmd("~/.config/hypr/lid-display.sh closed"), { locked = true })
hl.bind("switch:off:Lid Switch", hl.dsp.exec_cmd("~/.config/hypr/lid-display.sh open"), { locked = true })
-- Equivalent to exec: run at startup and after configuration reloads.
hl.on("hyprland.start", function()
    hl.exec_cmd("~/.config/hypr/lid-display.sh sync")
end)
hl.on("config.reloaded", function()
    hl.exec_cmd("~/.config/hypr/lid-display.sh sync")
end)

require("autostart")
require("keybinds")
