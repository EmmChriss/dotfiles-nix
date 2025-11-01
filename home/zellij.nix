{config, ...}: {
  programs.zellij.enable = true;

  # NOTE(2025-01): home-manager KDL support is generic and not up to standard;
  # fixing the toKDL generator was deemed unworthy of anyone's time and there
  # seems to be no alternative solution that is Zellij specific. In the mean
  # while, this seems to be the recommended solution.
  home.file."${config.home.homeDirectory}/.config/zellij/config.kdl" = {
    enable = true;
    source = ./config/zellij.kdl;
  };
}
