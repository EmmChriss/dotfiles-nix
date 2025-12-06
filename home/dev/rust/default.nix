{
  lib,
  config,
  pkgs,
  ...
}: {
  home = {
    packages = [pkgs.rustup];

    sessionVariables.CARGO_TARGET_DIR = lib.mkMerge [
      (lib.mkIf config.xdg.enable "${config.xdg.cacheHome}/target")
      (lib.mkIf (!config.xdg.enable) "${config.home.homeDirectory}/.cache/target")
    ];

    sessionPath = ["$HOME/.cargo/bin"];
  };
}
