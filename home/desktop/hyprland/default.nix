{...}: {
  imports = [
    ./uwsm.nix
    ./smart-gaps.nix
    ./keybinds.nix
  ];

  # enable hyprland
  # WARN: do not set any additional options, use the Hyprland that is installed system-wide
  wayland.windowManager.hyprland = {
    enable = true;

    # NOTE: in UWSM-managed environments, this is a conflict
    systemd.enable = false;

    settings = {
      debug = {
        disable_logs = false;
        disable_time = false;
      };

      # Monitors
      # See https://wiki.hyprland.org/Configuring/Monitors/
      monitor = [
        ",preferred,auto,1"
        "desc:Lenovo Group Limited LEN L220xwC VL-18504,preferred,auto-right,1"
        "desc:Philips Consumer Electronics Company Philips 226V4 UK01342044314,preferred,auto-left,1"
        "desc:Philips Consumer Electronics Company PHL 273V7 0x00000F8E,1920x1080@74.97,auto-right,1"
        # "desc:Technical Concepts Ltd Beyond TV 0x00010000,1920x1080@59.938999Hz,1"
      ];

      # Workspaces
      workspace = [
        "1,monitor:desc:AU Optronics 0xD1ED,name:1,default:true"
        "2,monitor:desc:AU Optronics 0xD1ED,name:2"
        "3,monitor:desc:AU Optronics 0xD1ED,name:3"
        "4,monitor:desc:AU Optronics 0xD1ED,name:4"
        "5,monitor:desc:AU Optronics 0xD1ED,name:5"
        "6,monitor:desc:AU Optronics 0xD1ED,name:6"
        "7,monitor:desc:AU Optronics 0xD1ED,name:7"
        "8,monitor:desc:AU Optronics 0xD1ED,name:8"
        "9,monitor:desc:AU Optronics 0xD1ED,name:9"
        "10,monitor:desc:AU Optronics 0xD1ED,name:10"

        "11,monitor:HDMI-A-1,name:I,default:true"
        "12,monitor:HDMI-A-1,name:II"
        "13,monitor:HDMI-A-1,name:III"
        "14,monitor:HDMI-A-1,name:IV"
        "15,monitor:HDMI-A-1,name:V"
        "16,monitor:HDMI-A-1,name:VI"
        "17,monitor:HDMI-A-1,name:VII"
        "18,monitor:HDMI-A-1,name:VIII"
        "19,monitor:HDMI-A-1,name:IX"
        "20,monitor:HDMI-A-1,name:X"
      ];

      windowrule = [
        # pinentry maintains focus
        "stayfocused, class:(pinentry)(.*)"
      ];

      # See https://wiki.hyprland.org/Configuring/Variables/ for more
      input = {
        # layout
        kb_layout = "us,hu,ro";
        kb_variant = ",qwerty";
        kb_model = "pc105";
        kb_options = "grp:shifts_toggle";
        kb_rules = "";

        # keyboard
        repeat_rate = 50;
        repeat_delay = 300;
        numlock_by_default = true;

        # touchpad
        scroll_method = "2fg";
        follow_mouse = 2;
        float_switch_override_focus = 2;

        touchpad = {
          tap-to-click = true;
          drag_lock = true;
          middle_button_emulation = true;
          natural_scroll = false;
        };
      };

      general = {
        gaps_in = "3";
        gaps_out = "5";
        border_size = "1";
        "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
        "col.inactive_border" = "rgba(595959aa)";

        layout = "dwindle";
        no_focus_fallback = "true";
        no_border_on_floating = "true";
      };

      decoration = {
        rounding = "3";

        blur = {
          enabled = "true";
          size = "3";
          passes = "1";
          xray = "false";
        };

        shadow = {
          enabled = "true";
          range = "4";
          render_power = "3";
          color = "rgba(1a1a1aee)";
        };
      };

      animations = {
        enabled = "true";

        # Some default animations, see https://wiki.hyprland.org/Configuring/Animations/ for more

        animation = [
          "windows, 1, 7, default"
          "windowsOut, 1, 7, default, popin 80%"
          "border, 1, 10, default"
          "borderangle, 1, 8, default"
          "fade, 1, 7, default"
          "workspaces, 1, 6, default"
        ];
      };

      dwindle = {
        # See https://wiki.hyprland.org/Configuring/Dwindle-Layout/ for more
        pseudotile = "true # master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below";
        preserve_split = "true # you probably want this";
        # smart_split = "true";
      };

      master = {
        # See https://wiki.hyprland.org/Configuring/Master-Layout/ for more
        # new_is_master = "true";
      };

      binds = {
        movefocus_cycles_fullscreen = "false";
      };

      misc = {
        disable_hyprland_logo = "true";
        disable_splash_rendering = "true";
        force_default_wallpaper = "0";
        vrr = "1";

        mouse_move_enables_dpms = "true";
        key_press_enables_dpms = "true";

        animate_manual_resizes = "true";
        animate_mouse_windowdragging = "true";
      };
    };
  };
}
