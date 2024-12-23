{ pkgs, inputs, ... }:

{
  # enable hyprland
  # WARN: do not set any additional options, use the Hyprland that is installed system-wide
  wayland.windowManager.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    systemd.variables = ["--all"];
    extraConfig = builtins.readFile ./config/hyprland.conf;
    # TODO: use hyprland-plugins flake input
    # plugins = with pkgs.hyprlandPlugins; [
    #   hyprbars hyprexpo
    # ];
  };
}
