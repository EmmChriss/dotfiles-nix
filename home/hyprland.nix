{ pkgs, lib, ... }:

let
  inherit (lib) getExe;
  hypr-slurp= pkgs.writeShellApplication {
    name = "hypr-slurp";
    runtimeInputs = with pkgs; [ hyprland jq slurp ];
    text = ''
      hyprctl clients -j |\
      jq -r ".[] | select(.workspace.id | IN($(hyprctl -j monitors | jq 'map(.activeWorkspace.id) | join(",")' | tr -d \")))" |\
      jq -r ".at,.size" |\
      jq -s "add" |\
      jq '_nwise(4)' |\
      jq -r '"\(.[0]),\(.[1]) \(.[2])x\(.[3])"' |\
      slurp
    '';
  };
  start-alacritty = pkgs.writeShellApplication {
    name = "start-alacritty";
    runtimeInputs = with pkgs; [ alacritty ];
    text = ''
      export ALACRITTY_SOCKET="$XDG_RUNTIME_DIR/alacritty.sock"
      if test -e "$ALACRITTY_SOCKET"; then
        alacritty msg create-window
      else
        alacritty --socket "$ALACRITTY_SOCKET"
      fi
    '';
  };
  printscrOutput = ''"$HOME/Media/Pictures/Screenshots/$(date +'%Y-%m-%d-%T').png"'';
  sattyArgs = ''--early-exit --copy-command wl-copy --save-after-copy'';
  grimArgs = ''-c -l9 -t ppm'';
in
{
  xdg.configFile."uwsm/env-hyprland" = { text =
    ''
      export AQ_DRM_DEVICES=$(readlink -f /dev/dri/by-path/pci-0000:05:00.0-card):$(readlink -f /dev/dri/by-path/pci-0000:01:00.0-card)
    ''; };

  xdg.configFile."uwsm/env" = { text =
    ''
      export XCURSOR_SIZE=24

      export QT_QPA_PLATFORM='wayland;xcb'
      export QT_AUTO_SCREEN_SCALE_FACTOR=1
      export QT_WAYLAND_DISABLE_WINDOWDECORATION=1

      export ELECTRON_OZONE_PLATFORM_HINT=auto
      export GDK_BACKEND=wayland,x11
      export SDL_VIDEODRIVER=wayland
      export CLUTTER_BACKEND=wayland

      export MOZ_ENABLE_WAYLAND=1

      export _JAVA_AWT_WM_NONREPARENTING=1
      export _JAVA_OPTIONS='-Dsun.java2d.opengl=true -Dawt.useSystemAAFontSettings=on -Dswing.aatext=true'
      export CRYPTOGRAPHY_OPENSSL_NO_LEGACY='1'
      export NODE_OPTIONS='--max-old-space-size=1024'
      export OGL_DEDICATED_HW_STATE_PER_CONTEXT='ENABLE_ROBUST'
    ''; };

  # enable hyprland
  # WARN: do not set any additional options, use the Hyprland that is installed system-wide
  wayland.windowManager.hyprland = {
    enable = true;

    # NOTE: in UWSM-managed environments, this is a conflict
    systemd.enable = false;

    # TODO: separate settings from binds
    # TODO: think about modal keybinds stuff, would be cool huh?
    # TODO: generate parts of the config
    settings = {
      debug = {
        disable_logs = false;
        disable_time = false;
      };

      cursor.no_hardware_cursors = true;

      # Monitors
      # See https://wiki.hyprland.org/Configuring/Monitors/
      monitor = [
        ",preferred,auto,1"
      ];

      # Workspaces
      # TODO: generate this
      workspace = [
        "1,monitor:eDP-2,name:1,default:true"
        "2,monitor:eDP-2,name:2"
        "3,monitor:eDP-2,name:3"
        "4,monitor:eDP-2,name:4"
        "5,monitor:eDP-2,name:5"
        "6,monitor:eDP-2,name:6"
        "7,monitor:eDP-2,name:7"
        "8,monitor:eDP-2,name:8"
        "9,monitor:eDP-2,name:9"
        "10,monitor:eDP-2,name:10"

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

        # smart gaps part 1; see windowrules for part 2
        "w[tv1], gapsout:0, gapsin:0"
        "f[1], gapsout:0, gapsin:0"
      ];

      # smart gaps part 2
      windowrule = [
        "bordersize 0, floating:0, onworkspace:w[tv1]"
        "rounding 0, floating:0, onworkspace:w[tv1]"
        "bordersize 0, floating:0, onworkspace:f[1]"
        "rounding 0, floating:0, onworkspace:f[1]"
      ];

      #
      # Autostart
      #

      exec = [
        # try restarting units that failed
        # solves stuff caused by UWSM in graphical user units
        # NOTE: forcefully reset and restart failed units
        "systemctl --user --quiet list-units --failed | xargs -I{} sh -c 'systemctl --user stop {}; systemctl --user reset-failed {}; systemctl --user restart {}'"
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

          touchpad =  {
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

      gestures = {
          workspace_swipe = "true";
          workspace_swipe_forever = "true";
          workspace_swipe_use_r = "true";
          workspace_swipe_direction_lock = "false";
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
      
      # KEYBINDS
      # See bind modifiers: https://wiki.hyprland.org/Configuring/Binds/#bind-flags
      "$mainMod" = "SUPER";
      "$mainModKey" = "SUPER_L";

      # PROGRAMS
      "$exitcmd" = "hyprctl dispatch exit";
      "$terminal" = "xargs uwsm app -- ${getExe start-alacritty}";
      "$browser"  = "xargs uwsm app -- librewolf";
      "$editor"   = "helix";
      "$clipman" = "cliphist list | tofi --prompt-text= --placeholder-text='Copy' | cliphist decode | wl-copy";
      "$launcher" = "tofi-run --prompt-text= --placeholder-text='Run application' | xargs uwsm app --";
      "$dlauncher" = "tofi-drun --prompt-text= --placeholder-text='Run application' --drun-print-desktop=true | xargs uwsm app --";
      "$printscr" = ''${getExe pkgs.grim} ${grimArgs} - | ${getExe pkgs.satty} ${sattyArgs} -f - -o ${printscrOutput}'';
      "$printscrSelect" = ''${getExe pkgs.grim} ${grimArgs} -g "$(${getExe hypr-slurp})" - | ${getExe pkgs.satty} ${sattyArgs} -f - -o ${printscrOutput}'';
      "$playerctl" = "${getExe pkgs.playerctl}";

      bind = [
        # show/hide nwg-dock
        "$mainMod, D, exec, pkill -10 nwg-dock"

        # Applications
        "$mainMod,      Space,  exec, $dlauncher"
        "$mainMod CTRL, Space,  exec, $launcher"
        "$mainMod,      Return, exec, $terminal"
        "$mainMod,      Escape, exec, hyprctl reload"
        "$mainMod CTRL, Escape, exec, $exitcmd"
        "$mainMod,      c,      exec, $clipman"

        "$mainMod,      Q,      killactive"
        "$mainMod,      S,      togglefloating"
        "$mainMod,      T,      pseudo"
        "$mainMod,      J,      togglesplit"
        "$mainMod,      F,      fullscreen, 0"
        "$mainMod,      P,      pin"
        "$mainMod CTRL, F,      fullscreen, 1"

        # Switch focus with mainMod + arrow keys
        "$mainMod, left, movefocus, l"
        "$mainMod, right, movefocus, r"
        "$mainMod, up, movefocus, u"
        "$mainMod, down, movefocus, d"

        # Move window with mainMod shift + arrow keys
        "$mainMod SHIFT, left, movewindow, l"
        "$mainMod SHIFT, right, movewindow, r"
        "$mainMod SHIFT, up, movewindow, u"
        "$mainMod SHIFT, down, movewindow, d"

        # Switch workspaces with mainMod + [0-9]
        "$mainMod, 1, workspace, 1"
        "$mainMod, 2, workspace, 2"
        "$mainMod, 3, workspace, 3"
        "$mainMod, 4, workspace, 4"
        "$mainMod, 5, workspace, 5"
        "$mainMod, 6, workspace, 6"
        "$mainMod, 7, workspace, 7"
        "$mainMod, 8, workspace, 8"
        "$mainMod, 9, workspace, 9"
        "$mainMod, 0, workspace, 10"

        # Switch workspaces with mainMod + ALT + [0-9]
        "$mainMod ALT, 1, workspace, 11"
        "$mainMod ALT, 2, workspace, 12"
        "$mainMod ALT, 3, workspace, 13"
        "$mainMod ALT, 4, workspace, 14"
        "$mainMod ALT, 5, workspace, 15"
        "$mainMod ALT, 6, workspace, 16"
        "$mainMod ALT, 7, workspace, 17"
        "$mainMod ALT, 8, workspace, 18"
        "$mainMod ALT, 9, workspace, 19"
        "$mainMod ALT, 0, workspace, 20"

        # Move window to a workspace with mainMod + SHIFT + [0-9]
        "$mainMod SHIFT, 1, movetoworkspacesilent, 1"
        "$mainMod SHIFT, 2, movetoworkspacesilent, 2"
        "$mainMod SHIFT, 3, movetoworkspacesilent, 3"
        "$mainMod SHIFT, 4, movetoworkspacesilent, 4"
        "$mainMod SHIFT, 5, movetoworkspacesilent, 5"
        "$mainMod SHIFT, 6, movetoworkspacesilent, 6"
        "$mainMod SHIFT, 7, movetoworkspacesilent, 7"
        "$mainMod SHIFT, 8, movetoworkspacesilent, 8"
        "$mainMod SHIFT, 9, movetoworkspacesilent, 9"
        "$mainMod SHIFT, 0, movetoworkspacesilent, 10"

        # Move window to a workspace with mainMod + ALT + SHIFT + [0-9]
        "$mainMod ALT SHIFT, 1, movetoworkspacesilent, 11"
        "$mainMod ALT SHIFT, 2, movetoworkspacesilent, 12"
        "$mainMod ALT SHIFT, 3, movetoworkspacesilent, 13"
        "$mainMod ALT SHIFT, 4, movetoworkspacesilent, 14"
        "$mainMod ALT SHIFT, 5, movetoworkspacesilent, 15"
        "$mainMod ALT SHIFT, 6, movetoworkspacesilent, 16"
        "$mainMod ALT SHIFT, 7, movetoworkspacesilent, 17"
        "$mainMod ALT SHIFT, 8, movetoworkspacesilent, 18"
        "$mainMod ALT SHIFT, 9, movetoworkspacesilent, 19"
        "$mainMod ALT SHIFT, 0, movetoworkspacesilent, 20"

        # Switch neighboring workspace with mainMod + []
        "$mainMod, bracketleft,  workspace, r-1"
        "$mainMod, bracketright, workspace, r+1"

        # Move window to neighboring workspace with mainMod + SHIFT + []
        "$mainMod SHIFT, code:34, movetoworkspacesilent, r-1"
        "$mainMod SHIFT, code:35, movetoworkspacesilent, r+1"

        # Cycle throught windows on workspace with mainMod + `
        "$mainMod, grave, cyclenext"

        # Cycle through monitors with mainMod + ALT + `
        "$mainMod ALT, grave, focusmonitor, +1"

        # Move window to next monitor with mainMod + ALT + SHIFT + `
        "$mainMod ALT SHIFT, grave, movewindow, mon:+1"
      ];

      bindm = [
        # Move/resize windows with mainMod + LMB/RMB and dragging
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
      ];

      bindl = [
        # player control
        ", XF86AudioNext, exec, $playerctl next"
        ", XF86AudioPrev, exec, $playerctl previous"
        ", XF86AudioStop, exec, $playerctl stop"
        '', XF86AudioPlay, exec, test "$(playerctl status)" = 'Playing' && playerctl pause || playerctl play''
      
        # screenshot
        ", Print, exec, $printscr"
        "$mainMod, Print, exec, $printscrSelect"

        # audio: toggle mute
        ", XF86AudioMute, exec, vol mute"
        ", XF86AudioMicMute, exec, vol mic mute"

        # trigger when the switch is toggled
        # '', switch:33642de0, exec, swaylock''
        # trigger when the switch is turning on
        # '', switch:on:33642de0, exec, hyprctl keyword monitor "eDP-1, disable"''
        # trigger when the switch is turning off
        # '', switch:off:33642de0, exec, hyprctl keyword monitor "eDP-1, 2560x1600, 0x0, 1"''
      ];

      bindle = [
        # audio: volume control
        ", XF86AudioRaiseVolume, exec, vol 5%+"
        ", XF86AudioLowerVolume, exec, vol 5%-"
        
        # brightness
        ", XF86MonBrightnessUp, exec, bl +5"
        ", XF86MonBrightnessDown, exec, bl -5"
      ];
    };
  };
}
