-- Personal bindings for Omarchy 4 (loaded after Omarchy defaults).
-- Keep Omarchy's own Hyprland and session configuration intact.
local function bind(key, description, action)
  hl.unbind(key)
  o.bind(key, description, action)
end
local function dispatch(key, description, command)
  bind(key, description, "hyprctl dispatch " .. command)
end

-- Applications
bind("SUPER + T", "Ghostty", { launch = "ghostty" })
bind("SUPER + E", "Files", { launch = "thunar" })
bind("SUPER + C", "Chromium", { launch = "chromium" })
bind("SUPER + A", "LocalSend", { launch = "localsend" })
bind("SUPER + R", "Remmina", { launch = "remmina" })
bind("SUPER + SHIFT + M", "Aerion Mail", "env WEBKIT_DISABLE_COMPOSITING_MODE=1 aerion")
bind("SUPER + SHIFT + E", "Enpass", { launch = "enpass" })
bind("SUPER + SHIFT + I", "Signal", { launch = "signal-desktop" })
bind("SUPER + SHIFT + W", "WhatsApp", "chromium --app=https://web.whatsapp.com/")
bind("SUPER + SHIFT + Y", "YouTube", "chromium --app=https://youtube.com/")

-- Windows and Vim-style movement
bind("SUPER + Q", "Close window", "hyprctl dispatch killactive")
bind("SUPER + F", "Fullscreen", "hyprctl dispatch fullscreen 0")
bind("SUPER + SHIFT + V", "Floating full width", "hyprctl dispatch togglefloating && hyprctl dispatch fullscreen 1")
local dirs = { H = "l", J = "d", K = "u", L = "r" }
for key, dir in pairs(dirs) do
  bind("SUPER + " .. key, "Focus " .. dir, "hyprctl dispatch movefocus " .. dir)
  bind("SUPER + CTRL + " .. key, "Move window " .. dir, "hyprctl dispatch movewindow " .. dir)
end
local sizes = { H = "-50 0", J = "0 50", K = "0 -50", L = "50 0" }
for key, delta in pairs(sizes) do
  dispatch("SUPER + SHIFT + " .. key, "Resize " .. key, "resizeactive " .. delta)
end
-- Avoid duplicate SUPER+SHIFT+A: gather wins over the 50% ratio preset.
dispatch("SUPER + SHIFT + S", "Split ratio 66%", "layoutmsg 'splitratio 0.666 exact'")
dispatch("SUPER + SHIFT + D", "Split ratio 100%", "layoutmsg 'splitratio 1.0 exact'")
dispatch("SUPER + SHIFT + F", "Split ratio 133%", "layoutmsg 'splitratio 1.333 exact'")
bind("SUPER + SHIFT + A", "Gather workspaces", os.getenv("HOME") .. "/dotfiles/linux/hypr/gather-workspaces.sh")

-- Group mode uses Hyprland's native submap dispatchers.
-- Group submap requires a separate compatible Lua definition; do not bind a dead shortcut.
-- Submap bindings are defined separately by the installer in the optional legacy
-- config only if a future Omarchy release exposes submap configuration in Lua.

-- Workspaces
for n = 1, 9 do
  local key = "code:" .. tostring(n + 9)
  bind("SUPER + " .. key, "Workspace " .. n, "hyprctl dispatch workspace " .. n)
  bind("SUPER + SHIFT + " .. key, "Move to workspace " .. n, "hyprctl dispatch movetoworkspace " .. n)
end
bind("SUPER + N", "Next workspace", "hyprctl dispatch workspace r+1")
bind("SUPER + B", "Previous workspace", "hyprctl dispatch workspace r-1")
bind("SUPER + SHIFT + N", "Move to next workspace", "hyprctl dispatch movetoworkspace r+1")
bind("SUPER + SHIFT + B", "Move to previous workspace", "hyprctl dispatch movetoworkspace r-1")
bind("SUPER + P", "Scratchpad", "hyprctl dispatch togglespecialworkspace scratchpad")
bind("SUPER + SHIFT + P", "Move to scratchpad", "hyprctl dispatch movetoworkspace special:scratchpad")

-- Omarchy owns session/lock, audio, media and screenshots. Retain its defaults.
