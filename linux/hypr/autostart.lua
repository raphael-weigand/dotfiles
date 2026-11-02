-- Start services once per Hyprland session, as in autostart.conf.
hl.on("hyprland.start", function()
    -- Status bar
    hl.exec_cmd("quickshell")
    -- Notifications
    hl.exec_cmd("mako")
    -- Authentication dialogs
    hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
    -- Clipboard history
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
    -- exec-once = sleep 1 && hyprpm reload && hyprctl reload
    -- Hyprpaper Wallpaper service
    hl.exec_cmd("hyprpaper")
    -- Hypridle intentionally not started yet: DPMS wake needs further testing on T2 hybrid graphics.
end)
