{
  pkgs,
  lib,
  ...
}: let
  latestHydro = pkgs.fishPlugins.hydro.overrideAttrs (old: {
    src = pkgs.fetchFromGitHub {
      owner = "jorgebucaran";
      repo = "hydro";
      rev = "75ab7168a35358b3d08eeefad4ff0dd306bd80d4";
      hash = "sha256-QYq4sU41/iKvDUczWLYRGqDQpVASF/+6brJJ8IxypjE=";
    };
  });
  greetings = pkgs.writeShellApplication {
    name = "greetings";
    runtimeInputs = with pkgs; [
      neo-cowsay
      fortune
    ];
    text = ''
      fortune | cowthink --rainbow --bold -n
      cat <<- EOF
      Hello $USER!
      <c-f> to open file manager
      <c-t> to fuzzy search files
      EOF
    '';
  };
in {
  home.packages = [pkgs.grc];

  # enable fish shell
  programs.fish = {
    enable = true;
    plugins = with pkgs.fishPlugins; [
      # Colorized nixpkgs command output
      {
        name = "grc";
        src = grc.src;
      }
      # Hydro prompt
      {
        name = "hydro";
        src = latestHydro.src;
      }
      # Import foregin envs (aka. bash or conf)
      {
        name = "foreign-env";
        src = foreign-env.src;
      }
      # Receive notifications when process done
      {
        name = "done";
        src = done.src;
      }
      # Colored man-pages
      {
        name = "colored-man";
        src = colored-man-pages.src;
      }
    ];
    functions.fish_greeting = "";

    # TODO: check out Hydro documentation
    # See: https://github.com/jorgebucaran/hydro
    interactiveShellInit = ''
      # hydro: indicate root
      test "$USER" = root && set -g hydro_symbol_prompt "[ROOT] ❱"

      # hydro: show nix shell
      test -n "$IN_NIX_SHELL" && set -g hydro_symbol_prompt "[NIX] ❱"

      # mark subshells with FISH_TOP=1
      test -z "$FISH_TOP" && ${lib.getExe greetings} && set -x FISH_TOP 1
    '';
  };
}
