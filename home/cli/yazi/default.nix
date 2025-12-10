{pkgs, ...}: let
  yazi-plugins = pkgs.fetchFromGitHub {
    owner = "yazi-rs";
    repo = "plugins";
    rev = "19dc890e33b8922eb1a3a165e685436ec4ac0a59";
    hash = "sha256-Hml7n07G6tEOPUPOFN9jf01C5LtZRO8pfERVHKHJQRo=";
  };
in {
  # Generated theme
  # To customize, see: https://github.com/lpnh/icons-brew.yazi
  xdg.configFile."yazi/theme.toml".source = ./catppuccin.toml;

  programs.yazi = {
    enable = true;
    enableFishIntegration = true;
    shellWrapperName = "y";

    settings = {
      mgr.show_hidden = true;
    };

    plugins = {
      chmod = "${yazi-plugins}/chmod.yazi";
    };
  };
}
