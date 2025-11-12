{pkgs, ...}: {
  home.packages = [pkgs.fnm];

  home.sessionVariables = {
    FNM_VERSION_FILE_STRATEGY = "recursive";
    FNM_COREPACK_ENABLED = "true";
    FNM_RESOLVE_ENGINES = "true";
  };

  programs.fish.interactiveShellInit = "fnm env --shell fish | source";
}
