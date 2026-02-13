{config, ...}: let
  cfg = config.home.vcs;
in {
  programs.git = {
    enable = true;

    # git large file support
    lfs.enable = true;

    # automatic git signing
    signing = {
      format = "ssh";
      signByDefault = true;
      key = cfg.signature;
    };

    settings.user = {inherit (cfg) name email;};
  };

  # git diff highlighter
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate = true;
      side-by-side = true;
    };
  };

  # gitui
  programs.gitui.enable = true;
}
