{...}: {
  wayland.windowManager.hyprland.settings = {
    workspace = [
      "w[tv1], gapsout:0, gapsin:0"
      "f[1], gapsout:0, gapsin:0"
    ];

    windowrule = [
      # tag windows
      "tag +smart_gaps, floating:0, onworkspace:w[tv1]"
      "tag +smart_gaps, floating:0, onworkspace:f[1]"
      # except some
      "tag -smart_gaps, class:REAPER"

      # rules for smart-gaps
      "bordersize 0, tag:smart_gaps"
      "rounding 0, tag:smart_gaps"
    ];
  };
}
