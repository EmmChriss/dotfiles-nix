{ config, ... }:

{
  programs.zellij = {
    enable = true;
    enableFishIntegration = true;
    enableBashIntegration = true;
  };

  # home-manager doesn't yet support the KDL file format used by new zellij versions
  home.file."${config.home.homeDirectory}/.config/zellij/config.kdl" = {
    enable = true;
    source = ./config/zellij.kdl;
  };
}
