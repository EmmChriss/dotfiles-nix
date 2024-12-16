{ pkgs, config, ... }:

# TODO: port config to nix
{
  programs.lf = {
    enable = true;
    extraConfig = builtins.readFile ./lfrc;
  };
}
