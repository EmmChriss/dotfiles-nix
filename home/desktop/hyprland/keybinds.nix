{
  pkgs,
  lib,
  ...
}: let
  inherit (lib) getExe;
  hypr-slurp = pkgs.writeShellApplication {
    name = "hypr-slurp";
    runtimeInputs = with pkgs; [
      hyprland
      jq
      slurp
    ];
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
  printscrOutput = ''"$HOME/Media/Pictures/Screenshots/$(date +'%Y-%m-%d-%T').png"'';
  sattyArgs = ''--early-exit --copy-command wl-copy --save-after-copy'';
  grimArgs = ''-c -l9 -t ppm'';
in {
  wayland.windowManager.hyprland.settings = {
    # KEYBINDS
    # See bind modifiers: https://wiki.hyprland.org/Configuring/Binds/#bind-flags
    "$mainMod" = "SUPER";
    "$mainModKey" = "SUPER_L";

    # PROGRAMS
    "$exitcmd" = "uwsm stop";
    "$terminal" = "xargs uwsm-app -- alacritty";
    "$browser" = "xargs uwsm-app -- librewolf";
    "$editor" = "hx";
    "$launcher" = "tofi-run --prompt-text= --placeholder-text='Run application' | xargs -r uwsm-app --";
    "$dlauncher" = "tofi-drun --prompt-text= --placeholder-text='Run application' --drun-print-desktop=true | xargs -r uwsm-app --";
    "$printscr" = ''${getExe pkgs.grim} ${grimArgs} - | ${getExe pkgs.satty} ${sattyArgs} -f - -o ${printscrOutput}'';
    "$printscrSelect" = ''${getExe pkgs.grim} ${grimArgs} -g "$(${getExe hypr-slurp})" - | ${getExe pkgs.satty} ${sattyArgs} -f - -o ${printscrOutput}'';
    "$playerctl" = "${getExe pkgs.playerctl}";

    bind = [
      # Applications
      "$mainMod,      Space,  exec, $dlauncher"
      "$mainMod CTRL, Space,  exec, $launcher"
      "$mainMod,      Return, exec, $terminal"
      "$mainMod,      Escape, exec, hyprctl reload"
      "$mainMod CTRL, Escape, exec, $exitcmd"

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
}
