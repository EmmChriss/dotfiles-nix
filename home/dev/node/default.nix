{pkgs, ...}: {
  home = {
    packages = [pkgs.fnm];

    sessionVariables = {
      FNM_VERSION_FILE_STRATEGY = "recursive";
      FNM_COREPACK_ENABLED = "true";
      FNM_RESOLVE_ENGINES = "true";
    };
  };

  programs.fish.interactiveShellInit = "fnm env --shell fish --use-on-cd | source";
}
