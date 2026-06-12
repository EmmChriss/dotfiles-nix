-- Monitors
-- See https://wiki.hyprland.org/Configuring/Monitors/
hl.monitor({
  output = "";
  mode = "preferred";
  position = "auto";
  scale = 1;
})

hl.monitor({
  output = "desc:Lenovo Group Limited LEN L220xwC VL-18504";
  mode = "preferred";
  position = "auto-right";
  scale = 1;
})

hl.monitor({
  output = "desc:Philips Consumer Electronics Company Philips 226V4 UK01342044314";
  mode = "preferred";
  position = "auto-left";
  scale = 1;
})

hl.monitor({
  output = "desc:Philips Consumer Electronics Company PHL 273V7 0x00000F8E";
  mode = "1920x1080@74.97";
  position = "auto-right";
  scale = 1;
})


-- Workspaces
-- See https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/

hl.workspace_rule({ workspace = "1", default = true })
hl.workspace_rule({ workspace = "11", default = true })

for i = 1, 10 do
  -- default workspace for builtin monitor
  hl.workspace_rule({
    workspace = tostring(i),
    monitor = "desc:AU Optronics 0xD1ED",
    default_name = tostring(i),
  })

  -- default workspace for external monitor
  hl.workspace_rule({
    workspace = tostring(10 + i),
    monitor = "HDMI-A-1",
    default_name = tostring(10 + i),
  })
end

-- Smart gaps: no gaps when only window on workspace
hl.workspace_rule({ workspace = "w[tv1]", gaps_out = 0, gaps_in = 0 })
hl.workspace_rule({ workspace = "f[1]", gaps_out = 0, gaps_in = 0 })

-- tag windows for smart gaps
hl.window_rule({ match = { float = false, workspace = "w[tv1]" }, tag = "+sg" })
hl.window_rule({ match = { float = false, workspace = "f[1]" }, tag = "+sg" })

-- remove tag from exceptions
hl.window_rule({ match = { class = "REAPER" }, tag = "-sg" })

-- apply SG style to remaining tagged windows
hl.window_rule({ match = { tag = "sg" }, border_size = 0 })
hl.window_rule({ match = { tag = "sg" }, rounding = 0 })


-- Window rules
-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
hl.window_rule({
  match = { class = "(pinentry)(.*)" },
  stay_focused = true,
})


-- Animations
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/
hl.curve("overshoot", { type = "bezier", points = {{0.6, 0.25}, {0.3, 1}} })

hl.animation({ leaf = "windows", enabled = true, speed = 5, bezier = "overshoot" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 5, bezier = "overshoot", style = "popin 80%" })
hl.animation({ leaf = "border", enabled = true, speed = 10, bezier = "overshoot" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 8, bezier = "overshoot" })
hl.animation({ leaf = "fade", enabled = true, speed = 7, bezier = "overshoot" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 5, bezier = "overshoot" })
hl.animation({ leaf = "zoomFactor", enabled = true, speed = 1, bezier = "overshoot" })


-- Gestures
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
hl.gesture({ fingers = 2, direction = "pinch", action = "cursorZoom", zoom_level = 1, mode = "live" })


-- Keybinds
-- See https://wiki.hypr.land/Configuring/Basics/Binds/

-- applications
hl.bind("SUPER + Space",        hl.dsp.exec_cmd(dlauncher))
hl.bind("SUPER + CTRL + Space", hl.dsp.exec_cmd(launcher))
hl.bind("SUPER + Return",       hl.dsp.exec_cmd(terminal))

-- lifecycle
hl.bind("SUPER + Escape",        hl.dsp.exec_cmd("hyprctl reload"))
hl.bind("SUPER + CTRL + Escape", hl.dsp.exec_cmd(exitcmd))

-- window manipulation
hl.bind("SUPER + Q",         hl.dsp.window.close())
hl.bind("SUPER + SHIFT + Q", hl.dsp.window.kill())
hl.bind("SUPER + S",         hl.dsp.window.float())
hl.bind("SUPER + T",         hl.dsp.window.pseudo())
-- hl.bind("SUPER + J",      hl.dsp.window.togglesplit())
hl.bind("SUPER + F",         hl.dsp.window.fullscreen({ mode = "fullscreen" }))
hl.bind("SUPER + CTRL + F",  hl.dsp.window.fullscreen({ mode = "maximized" }))
hl.bind("SUPER + P",         hl.dsp.window.pin())

-- focus and move windows with arrow keys
for dir, key in pairs({ l = "left", r = "right", u = "up", d = "down" }) do
  hl.bind("SUPER + " .. key,         hl.dsp.focus({ direction = dir }))
  hl.bind("SUPER + SHIFT + " .. key, hl.dsp.window.move({ direction = dir }))
end

-- focus and move windows between workspaces with numbers
for i = 1, 10 do
  local k
  if i == 10 then
    k = 0
  else
    k = i
  end

  -- focus workspace
  hl.bind("SUPER + " .. tostring(k),       hl.dsp.focus({ workspace = tostring(i) }))
  hl.bind("SUPER + ALT + " .. tostring(k), hl.dsp.focus({ workspace = tostring(10 + i) }))
  -- move to workspace
  hl.bind("SUPER + SHIFT + " .. tostring(k),       hl.dsp.window.move({ workspace = tostring(i) }))
  hl.bind("SUPER + SHIFT + ALT + " .. tostring(k), hl.dsp.window.move({ workspace = tostring(10 + i) }))
end

-- focus and move windows between workspaces with brackets
hl.bind("SUPER + bracketleft",  hl.dsp.focus({ workspace = "r-1" }))
hl.bind("SUPER + bracketright", hl.dsp.focus({ workspace = "r+1" }))
hl.bind("SUPER + SHIFT + bracketleft",  hl.dsp.window.move({ workspace = "r-1" }))
hl.bind("SUPER + SHIFT + bracketright", hl.dsp.window.move({ workspace = "r+1" }))

-- cycle through and move windows with grave
hl.bind("SUPER + grave",               hl.dsp.window.cycle_next())
hl.bind("SUPER + ALT + grave",         hl.dsp.focus({ monitor = "+1" }))
hl.bind("SUPER + ALT + SHIFT + grave", hl.dsp.window.move({ monitor = "+1" }))

-- drag and resize with mouse clicks
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- audio and playerctl
hl.bind("XF86AudioNext",        hl.dsp.exec_cmd(playerctl .. " next"),     { locked = true, submap_universal = true })
hl.bind("XF86AudioPrev",        hl.dsp.exec_cmd(playerctl .. " previous"), { locked = true, submap_universal = true })
hl.bind("XF86AudioStop",        hl.dsp.exec_cmd(playerctl .. " stop"),     { locked = true, submap_universal = true })
hl.bind("XF86AudioPlay",        hl.dsp.exec_cmd(playerctl_start_stop),     { locked = true, submap_universal = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("vol mute"),               { locked = true, submap_universal = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("vol mic mute"),           { locked = true, submap_universal = true })
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("vol 5%+"),                { locked = true, submap_universal = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("vol 5%-"),                { locked = true, submap_universal = true, repeating = true })

-- brightness control
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("bl +5"), { locked = true, submap_universal = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("bl -5"), { locked = true, submap_universal = true, repeating = true })

-- screenshot
hl.bind("Print",         hl.dsp.exec_cmd(printscr))
hl.bind("SUPER + Print", hl.dsp.exec_cmd(printscrSelect))

-- zoom
hl.bind("SUPER + CTRL + mouse_up", function()
  local prev = hl.get_config("cursor.zoom_factor")
  local next = math.max(prev - 0.5, 1)
  hl.config({ cursor = { zoom_factor = next } })
end, { mouse = true })

hl.bind("SUPER + CTRL + mouse_down", function()
  local prev = hl.get_config("cursor.zoom_factor")
  local next = math.min(prev + 0.5, 10)
  hl.config({ cursor = { zoom_factor = next } })
end, { mouse = true })

