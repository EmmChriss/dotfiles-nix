{ pkgs, ... }:

{
  # enable hyprland
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    systemd.enable = true;
    systemd.variables = ["--all"];
    extraConfig = builtins.readFile ./config/hyprland.conf;
    # TODO: look into why these fail to load
    # plugins = with pkgs.hyprlandPlugins; [
    #   hyprbars hyprexpo
    # ];
  };
}
