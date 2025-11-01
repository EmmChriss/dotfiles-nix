{
  pkgs,
  lib,
  ...
}: let
  latestHydro = pkgs.fishPlugins.hydro.overrideAttrs (old: {
    src = pkgs.fetchFromGitHub {
      owner = "jorgebucaran";
      repo = "hydro";
      rev = "9c93b89573bd722f766f2190a862ae55e728f6ba";
      hash = "sha256-QYq4sU41/iKvDUczWLYRGqDQpVASF/+6brJJ8IxypjE=";
    };
  });
  greetings = pkgs.writeShellApplication {
    name = "greetings";
    runtimeInputs = with pkgs; [neo-cowsay fortune];
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
      # mark subshells with FISH_TOP=1
      test -z "$FISH_TOP" && ${lib.getExe greetings} && set -x FISH_TOP 1

      # ctrl-f to open file manager
      bind \cf 'lf; commandline -f repaint'
    '';
  };
}
