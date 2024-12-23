{ pkgs, inputs, ... }:

{
  # enable xdg hyprland portal
  # TODO: select portal
  xdg.portal = {
    enable = true;

    # use first portal for any given cap
    config.common.default = "*";
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-wlr
    ];
  };

  # enable hyprland
  wayland.windowManager.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    xwayland.enable = true;
    # systemd.enable = true;
    systemd.variables = ["--all"];
    extraConfig = builtins.readFile ./config/hyprland.conf;
    # TODO: look into why these fail to load
    # plugins = with pkgs.hyprlandPlugins; [
    #   hyprbars hyprexpo
    # ];
  };
}
