-- T2 MacBook Pro: Lua port of hyprland.conf.
-- Previous files are preserved in backup-before-lua-20261102/.

-- Connector numbering changes across boots. Disable the mode-less AMD eDP
-- phantom before framebuffer allocation, while leaving the real panel enabled.
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })
local function read_sysfs(path)
    local file = io.open(path, "rb")
    if not file then return nil end
    local value = file:read("*a")
    file:close()
    return value
end

-- Only shell glob expansion and printf; no device probes or waiting for IPC.
local connectors = assert(io.popen("printf '%s\\n' /sys/class/drm/card*-eDP-*", "r"))
for path in connectors:lines() do
    local card, output = path:match("^/sys/class/drm/(card%d+)%-([%w%-]+)$")
    if card
        and read_sysfs("/sys/class/drm/" .. card .. "/device/vendor") == "0x1002\n"
        and read_sysfs(path .. "/status") == "connected\n"
        and read_sysfs(path .. "/modes") == ""
        and read_sysfs(path .. "/edid") == ""
    then
        hl.monitor({ output = output, disabled = true })
    end
end
connectors:close()

hl.config({
    input = {
        kb_layout = "de",
        kb_options = "ctrl:nocaps",
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
-- Reconcile lid state at startup and reload; disable the phantom before startup.
hl.on("hyprland.start", function()
    hl.exec_cmd("~/.config/hypr/lid-display.sh sync")
end)
hl.on("config.reloaded", function()
    hl.exec_cmd("~/.config/hypr/lid-display.sh sync")
end)

require("autostart")
require("keybinds")
