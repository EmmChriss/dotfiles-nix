{ config, ... }:

{
  programs.zellij = {
    enable = true;

    # shell integration simply autostarts zellij on shell start
    # TODO: write (maybe dir-based) zellij start/attach script; configure zellij to deatach on quit
    # enableFishIntegration = true;
    # enableBashIntegration = true;
  };

  # home-manager doesn't yet support the KDL file format used by new zellij versions
  home.file."${config.home.homeDirectory}/.config/zellij/config.kdl" = {
    enable = true;
    source = ./config/zellij.kdl;
  };
}
