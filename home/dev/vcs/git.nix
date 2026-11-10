{...}: {
  programs.git = {
    enable = true;
    lfs.enable = true;
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

  programs.gitui.enable = true;
}
