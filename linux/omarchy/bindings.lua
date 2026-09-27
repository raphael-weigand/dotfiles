-- Personal Omarchy 4 Lua bindings. Keep the Omarchy defaults for system/media.
-- All compositor actions use native Lua dispatchers, never legacy hyprctl syntax.
local function bind(key, description, action)
  hl.unbind(key)
  o.bind(key, description, action)
end
local function app(key, description, command)
  bind(key, description, hl.dsp.exec_cmd(command))
end

-- Applications
app("SUPER + T", "Ghostty", "ghostty")
app("SUPER + E", "Files", "thunar")
app("SUPER + C", "Chromium", "chromium")
app("SUPER + A", "LocalSend", "localsend")
app("SUPER + R", "Remmina", "remmina")
app("SUPER + SHIFT + M", "Aerion Mail", "env WEBKIT_DISABLE_COMPOSITING_MODE=1 aerion")
app("SUPER + SHIFT + E", "Enpass", "enpass")
app("SUPER + SHIFT + I", "Signal", "signal-desktop")
app("SUPER + SHIFT + W", "WhatsApp", "chromium --app=https://web.whatsapp.com/")
app("SUPER + SHIFT + Y", "YouTube", "chromium --app=https://youtube.com/")

-- Window management
bind("SUPER + Q", "Close window", hl.dsp.window.close())
bind("SUPER + F", "Fullscreen", hl.dsp.window.fullscreen({ action = "toggle", mode = "fullscreen" }))
-- Maximized preserves Omarchy's gaps/bar; toggling float separately avoids
-- leaving tiled windows with a tiny stored floating size.
bind("SUPER + SHIFT + V", "Maximize window (with gaps)", hl.dsp.window.fullscreen({ action = "toggle", mode = "maximized" }))

local dirs = { H = "l", J = "d", K = "u", L = "r" }
for key, dir in pairs(dirs) do
  bind("SUPER + " .. key, "Focus " .. dir, hl.dsp.focus({ direction = dir }))
  bind("SUPER + CTRL + " .. key, "Move window " .. dir, hl.dsp.window.move({ direction = dir }))
end
local sizes = {
  H = { -50, 0 }, J = { 0, 50 }, K = { 0, -50 }, L = { 50, 0 },
}
for key, size in pairs(sizes) do
  bind("SUPER + SHIFT + " .. key, "Resize " .. key,
    hl.dsp.window.resize({ x = size[1], y = size[2], relative = true }))
end

-- Split ratio presets for dwindle
bind("SUPER + SHIFT + S", "Split ratio 66%", hl.dsp.layout("splitratio 0.666 exact"))
bind("SUPER + SHIFT + D", "Split ratio 100%", hl.dsp.layout("splitratio 1.0 exact"))
bind("SUPER + SHIFT + F", "Split ratio 133%", hl.dsp.layout("splitratio 1.333 exact"))

-- Workspaces: normal number keys (not layout-dependent keycodes)
for n = 1, 9 do
  bind("SUPER + " .. n, "Workspace " .. n, hl.dsp.focus({ workspace = tostring(n) }))
  bind("SUPER + SHIFT + " .. n, "Move to workspace " .. n,
    hl.dsp.window.move({ workspace = tostring(n) }))
end
bind("SUPER + N", "Next workspace", hl.dsp.focus({ workspace = "r+1" }))
bind("SUPER + B", "Previous workspace", hl.dsp.focus({ workspace = "r-1" }))
bind("SUPER + SHIFT + N", "Move to next workspace", hl.dsp.window.move({ workspace = "r+1" }))
bind("SUPER + SHIFT + B", "Move to previous workspace", hl.dsp.window.move({ workspace = "r-1" }))

-- Preserve Omarchy's existing SUPER+S scratchpad; add personal aliases.
bind("SUPER + P", "Scratchpad", hl.dsp.workspace.toggle_special("scratchpad"))
bind("SUPER + SHIFT + P", "Move to scratchpad",
  hl.dsp.window.move({ workspace = "special:scratchpad" }))

-- Same two-key group mode as linux/hypr/keybinds.conf on master.
-- A submap prevents SUPER+G from toggling the group before H/L is pressed.
bind("SUPER + G", "Group mode", hl.dsp.submap("personal_group"))

local function group_action(key, description, action)
  hl.bind(key, function()
    hl.dispatch(action)
    hl.dispatch(hl.dsp.submap("reset"))
  end, { description = description })
end

hl.define_submap("personal_group", function()
  group_action("G", "Toggle window group", hl.dsp.group.toggle())
  group_action("H", "Previous group tab", hl.dsp.group.prev())
  group_action("L", "Next group tab", hl.dsp.group.next())
  group_action("M", "Move active window out of group",
    hl.dsp.window.move({ out_of_group = true }))
  hl.bind("ESCAPE", hl.dsp.submap("reset"), { description = "Exit group mode" })
end)

-- Omarchy owns session, lock, screenshots, clipboard, audio and brightness.
-- No T2-specific input or display overrides are installed here.
