{ pkgs, inputs, ... }:

{
  # enable hyprland
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    systemd.enable = true;
    systemd.variables = ["--all"];
    extraConfig = builtins.readFile ./hyprland.conf;
    plugins = with pkgs.hyprlandPlugins; [
      hyprbars hyprexpo
    ];
  };
}
