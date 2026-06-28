{
  inputs,
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
  home.packages = [
    # graphical window switcher
    inputs.snappy-switcher.packages.${pkgs.system}.default
  ];

  wayland.windowManager.hyprland.settings = {
    exitcmd._var = "uwsm stop";
    terminal._var = "xargs uwsm-app -- alacritty";
    browser._var = "xargs uwsm-app -- librewolf";
    editor._var = "hx";
    launcher._var = "tofi-run --prompt-text= --placeholder-text='Run application' | xargs -r uwsm-app --";
    dlauncher._var = "tofi-drun --prompt-text= --placeholder-text='Run application' --drun-print-desktop=true | xargs -r uwsm-app --";
    printscr._var = ''${getExe pkgs.grim} ${grimArgs} - | ${getExe pkgs.satty} ${sattyArgs} -f - -o ${printscrOutput}'';
    printscrSelect._var = ''${getExe pkgs.grim} ${grimArgs} -g "$(${getExe hypr-slurp})" - | ${getExe pkgs.satty} ${sattyArgs} -f - -o ${printscrOutput}'';
    playerctl._var = "${getExe pkgs.playerctl}";
    playerctl_start_stop._var = ''test "$($playerctl status)" = 'Playing' && $playerctl pause || $playerctl play'';
  };
}
