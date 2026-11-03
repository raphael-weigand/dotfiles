-- Keybindings ported from keybinds.conf; existing duplicates are intentional here.
-- Applications
hl.bind("SUPER + T", hl.dsp.exec_cmd("ghostty"))
hl.bind("SUPER + SPACE", hl.dsp.exec_cmd("fuzzel"))
hl.bind("SUPER + E", hl.dsp.exec_cmd("thunar"))
hl.bind("SUPER + C", hl.dsp.exec_cmd("chromium"))
hl.bind("SUPER + A", hl.dsp.exec_cmd("localsend"))
hl.bind("SUPER + R", hl.dsp.exec_cmd("remmina"))
hl.bind("SUPER + R", hl.dsp.exec_cmd("~/dotfiles/linux/hypr/focus-or-launch.sh org.remmina.Remmina remmina"))
-- Aerion Mail
hl.bind("SUPER + SHIFT + M", hl.dsp.exec_cmd("~/dotfiles/linux/hypr/focus-or-launch.sh io.github.hkdb.Aerion env WEBKIT_DISABLE_COMPOSITING_MODE=1 aerion"))
hl.bind("SUPER + SHIFT + E", hl.dsp.exec_cmd("~/dotfiles/linux/hypr/focus-or-launch.sh Enpass /usr/bin/enpass"))
hl.bind("SUPER + SHIFT + I", hl.dsp.exec_cmd("~/dotfiles/linux/hypr/focus-or-launch.sh signal /usr/bin/signal-desktop"))
-- WhatsApp
hl.bind("SUPER + SHIFT + W", hl.dsp.exec_cmd("~/dotfiles/linux/hypr/focus-or-launch.sh chrome-web.whatsapp.com__-Default chromium --app=https://web.whatsapp.com/"))
hl.bind("SUPER + SHIFT + Y", hl.dsp.exec_cmd("~/dotfiles/linux/hypr/focus-or-launch.sh chrome-youtube.com__-Default chromium --app=https://youtube.com"))

-- Windows
hl.bind("SUPER + Q", hl.dsp.window.close())
hl.bind("SUPER + F", hl.dsp.window.fullscreen({ mode = "fullscreen" }))
hl.bind("SUPER + SHIFT + V", function()
    hl.dispatch(hl.dsp.window.float({ action = "toggle" }))
    hl.dispatch(hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }))
end)
-- bind = SUPER, TAB, hymission:toggle

-- Vim-style focus navigation: mirrors Ctrl+H/J/K/L in Neovim
hl.bind("SUPER + H", hl.dsp.focus({ direction = "l" }))
hl.bind("SUPER + J", hl.dsp.focus({ direction = "d" }))
hl.bind("SUPER + K", hl.dsp.focus({ direction = "u" }))
hl.bind("SUPER + L", hl.dsp.focus({ direction = "r" }))

-- Vim-style tile resizing
hl.bind("SUPER + SHIFT + H", hl.dsp.window.resize({ x = -50, y = 0, relative = true }))
hl.bind("SUPER + SHIFT + J", hl.dsp.window.resize({ x = 0, y = 50, relative = true }))
hl.bind("SUPER + SHIFT + K", hl.dsp.window.resize({ x = 0, y = -50, relative = true }))
hl.bind("SUPER + SHIFT + L", hl.dsp.window.resize({ x = 50, y = 0, relative = true }))

-- Dwindle split-ratio presets for the active tile.
-- Left-to-right on the home row means smaller-to-larger.
hl.bind("SUPER + SHIFT + A", hl.dsp.layout("splitratio 0.5 exact"))
hl.bind("SUPER + SHIFT + S", hl.dsp.layout("splitratio 0.666 exact"))
hl.bind("SUPER + SHIFT + D", hl.dsp.layout("splitratio 1.0 exact"))
hl.bind("SUPER + SHIFT + F", hl.dsp.layout("splitratio 1.333 exact"))

-- # Split mode: mirrors <leader>s... in Neovim.
-- # SUPER+S, then H/V/C/X. Each action returns to the normal keymap.
-- bind = SUPER, S, submap, split
--
-- submap = split
-- bind = , H, exec, hyprctl dispatch layoutmsg "preselect d" && hyprctl dispatch exec ghostty && hyprctl dispatch submap reset
-- bind = , V, exec, hyprctl dispatch layoutmsg "preselect r" && hyprctl dispatch exec ghostty && hyprctl dispatch submap reset
-- bind = , C, exec, hyprctl dispatch killactive && hyprctl dispatch submap reset
-- bind = , X, exec, hyprctl dispatch layoutmsg swapsplit && hyprctl dispatch submap reset
-- bind = , ESCAPE, submap, reset
-- submap = reset

-- Window groups: multiple windows share one tile like tabs.
-- SUPER+G opens group mode. N launches another instance of the focused program
-- into the group without hardcoding an application name.
hl.bind("SUPER + G", hl.dsp.submap("group"))

hl.define_submap("group", function()
    local function once(dispatcher)
        return function()
            hl.dispatch(dispatcher)
            hl.dispatch(hl.dsp.submap("reset"))
        end
    end

    hl.bind("G", once(hl.dsp.group.toggle()))
    hl.bind("H", once(hl.dsp.group.prev()))
    hl.bind("L", once(hl.dsp.group.next()))
    hl.bind("M", once(hl.dsp.window.move({ out_of_group = true })))
    hl.bind("ESCAPE", hl.dsp.submap("reset"))
end)

-- Vim-inspired window mode: SUPER+W, then a command.
-- Keep direct SUPER+H/J/K/L navigation unchanged.
hl.bind("SUPER + W", hl.dsp.submap("window"))

hl.define_submap("window", function()
    local function once(action)
        return function()
            hl.dispatch(action)
            hl.dispatch(hl.dsp.submap("reset"))
        end
    end

    -- Like Vim's CTRL-W o, but closes real application windows.
    -- Only other windows on the focused workspace are affected.
    hl.bind("O", function()
        local focused = hl.get_active_window()
        local workspace = hl.get_active_special_workspace() or hl.get_active_workspace()
        if focused and workspace then
            for _, window in pairs(hl.get_windows({ workspace = workspace })) do
                if window.address ~= focused.address then
                    hl.dispatch(hl.dsp.window.close({ window = window }))
                end
            end
        end
        hl.dispatch(hl.dsp.submap("reset"))
    end)

    hl.bind("X", once(hl.dsp.window.swap({ next = true })))
    -- Equalize the current dwindle split (not every split in the workspace).
    hl.bind("SHIFT + 0", once(hl.dsp.layout("splitratio 1.0 exact")))
    hl.bind("F", function()
        local window = hl.get_active_window()
        if window then
            local was_floating = window.floating
            hl.dispatch(hl.dsp.window.float({ action = "toggle" }))
            if not was_floating then
                hl.dispatch(hl.dsp.window.center())
            end
        end
        hl.dispatch(hl.dsp.submap("reset"))
    end)
    hl.bind("ESCAPE", hl.dsp.submap("reset"))
end)

-- Desk control: SUPER+D opens desk mode. U/D/K use the same three profiles as Quickshell.
hl.bind("SUPER + D", hl.dsp.submap("desk"))

hl.define_submap("desk", function()
    hl.bind("U", hl.dsp.exec_cmd("~/.config/hypr/desk-control.sh stand && hyprctl dispatch submap reset"))
    hl.bind("D", hl.dsp.exec_cmd("~/.config/hypr/desk-control.sh sit && hyprctl dispatch submap reset"))
    hl.bind("K", hl.dsp.exec_cmd("~/.config/hypr/desk-control.sh high && hyprctl dispatch submap reset"))
    hl.bind("ESCAPE", hl.dsp.submap("reset"))
end)

-- Move windows directly while keeping Vim-style directions
hl.bind("SUPER + CTRL + H", hl.dsp.window.move({ direction = "l" }))
hl.bind("SUPER + CTRL + J", hl.dsp.window.move({ direction = "d" }))
hl.bind("SUPER + CTRL + K", hl.dsp.window.move({ direction = "u" }))
hl.bind("SUPER + CTRL + L", hl.dsp.window.move({ direction = "r" }))

-- Mouse window control
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Session
hl.bind("SUPER + SHIFT + Q", hl.dsp.exec_cmd("qs ipc call session toggle"))
hl.bind("SUPER + SHIFT + X", hl.dsp.exec_cmd("hyprlock"))

-- Workspaces
hl.bind("SUPER + 1", hl.dsp.focus({ workspace = "1" }))
hl.bind("SUPER + 2", hl.dsp.focus({ workspace = "2" }))
hl.bind("SUPER + 3", hl.dsp.focus({ workspace = "3" }))
hl.bind("SUPER + 4", hl.dsp.focus({ workspace = "4" }))
hl.bind("SUPER + 5", hl.dsp.focus({ workspace = "5" }))
hl.bind("SUPER + 6", hl.dsp.focus({ workspace = "6" }))
hl.bind("SUPER + 7", hl.dsp.focus({ workspace = "7" }))
hl.bind("SUPER + 8", hl.dsp.focus({ workspace = "8" }))
hl.bind("SUPER + 9", hl.dsp.focus({ workspace = "9" }))
hl.bind("SUPER + SHIFT + 1", hl.dsp.window.move({ workspace = "1", follow = true }))
hl.bind("SUPER + SHIFT + 2", hl.dsp.window.move({ workspace = "2", follow = true }))
hl.bind("SUPER + SHIFT + 3", hl.dsp.window.move({ workspace = "3", follow = true }))
hl.bind("SUPER + SHIFT + 4", hl.dsp.window.move({ workspace = "4", follow = true }))
hl.bind("SUPER + SHIFT + 5", hl.dsp.window.move({ workspace = "5", follow = true }))
hl.bind("SUPER + SHIFT + 6", hl.dsp.window.move({ workspace = "6", follow = true }))
hl.bind("SUPER + SHIFT + 7", hl.dsp.window.move({ workspace = "7", follow = true }))
hl.bind("SUPER + SHIFT + 8", hl.dsp.window.move({ workspace = "8", follow = true }))
hl.bind("SUPER + SHIFT + 9", hl.dsp.window.move({ workspace = "9", follow = true }))

-- Move active window silently: ALT+1..9 keeps the current workspace visible.
hl.bind("SUPER + ALT + 1", hl.dsp.window.move({ workspace = "1", follow = false }))
hl.bind("SUPER + ALT + 2", hl.dsp.window.move({ workspace = "2", follow = false }))
hl.bind("SUPER + ALT + 3", hl.dsp.window.move({ workspace = "3", follow = false }))
hl.bind("SUPER + ALT + 4", hl.dsp.window.move({ workspace = "4", follow = false }))
hl.bind("SUPER + ALT + 5", hl.dsp.window.move({ workspace = "5", follow = false }))
hl.bind("SUPER + ALT + 6", hl.dsp.window.move({ workspace = "6", follow = false }))
hl.bind("SUPER + ALT + 7", hl.dsp.window.move({ workspace = "7", follow = false }))
hl.bind("SUPER + ALT + 8", hl.dsp.window.move({ workspace = "8", follow = false }))
hl.bind("SUPER + ALT + 9", hl.dsp.window.move({ workspace = "9", follow = false }))

-- Relative workspace navigation through existing workspaces.
-- N = next, B = back. P stays reserved for the scratchpad below.
hl.bind("SUPER + N", hl.dsp.focus({ workspace = "r+1" }))
hl.bind("SUPER + B", hl.dsp.focus({ workspace = "r-1" }))
hl.bind("SUPER + SHIFT + N", hl.dsp.window.move({ workspace = "r+1", follow = true }))
hl.bind("SUPER + SHIFT + B", hl.dsp.window.move({ workspace = "r-1", follow = true }))

hl.bind("SUPER + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind("SUPER + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Scratchpad (SUPER+S is reserved for Neovim-style split mode)
hl.bind("SUPER + P", hl.dsp.workspace.toggle_special("scratchpad"))
hl.bind("SUPER + SHIFT + P", hl.dsp.window.move({ workspace = "special:scratchpad", follow = true }))

-- Audio
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+"), { repeating = true, locked = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { repeating = true, locked = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true })

-- Media
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

-- Brightness
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set +5%"), { repeating = true, locked = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"), { repeating = true, locked = true })

-- Clipboard
hl.bind("SUPER + V", hl.dsp.exec_cmd("cliphist list | fuzzel --dmenu | cliphist decode | wl-copy"))

-- Screenshots: save to Pictures, copy the PNG to the clipboard and notify when done
hl.bind("SUPER + CTRL + A", hl.dsp.exec_cmd("mkdir -p ~/Pictures && grim - | tee ~/Pictures/screenshot-$(date +'%Y-%m-%d_%H-%M-%S').png | wl-copy --type image/png && notify-send \"Screenshot\" \"Bild aufgenommen und kopiert\""))
hl.bind("SUPER + CTRL + S", hl.dsp.exec_cmd("mkdir -p ~/Pictures && grim -g \"$(slurp)\" - | tee ~/Pictures/screenshot-$(date +'%Y-%m-%d_%H-%M-%S').png | wl-copy --type image/png && notify-send \"Screenshot\" \"Bild aufgenommen und kopiert\""))
hl.bind("SUPER + CTRL + D", hl.dsp.exec_cmd("geometry=\"$(slurp)\" && sleep 5 && mkdir -p ~/Pictures && grim -g \"$geometry\" - | tee ~/Pictures/screenshot-$(date +'%Y-%m-%d_%H-%M-%S').png | wl-copy --type image/png && notify-send \"Screenshot\" \"Bild aufgenommen und kopiert\""))
