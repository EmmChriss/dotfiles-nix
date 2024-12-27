{ pkgs, lib, ... }:

let
    greetings = pkgs.writeShellApplication {
      name = "greetings";
      runtimeInputs = with pkgs; [ neo-cowsay fortune ];
      text = ''
        fortune | cowthink --rainbow --bold -n
        cat <<- EOF
        Hello $USER!
        <c-f> to open file manager
        <c-t> to fuzzy search files
        EOF
      '';
    };
  in
{
  home.packages = [ greetings ];

  # enable fish shell
  programs.fish = {
    enable = true;
    plugins = (with pkgs.fishPlugins; [
      # Colorized nixpkgs command output
      { name = "grc"; src = grc.src; }
      # Hydro prompt
      { name = "hydro"; src = hydro.src; }
      # Import foregin envs (aka. bash or conf)
      { name = "foreign-env"; src = foreign-env.src; }
      # Receive notifications when process done
      { name = "done"; src = done.src; }
      # Colored man-pages
      { name = "colored-man"; src = colored-man-pages.src; }
    ]);
    functions.fish_greeting = "";
    interactiveShellInit = builtins.readFile ./config/config.fish + ''
      test -z "$FISH_TOP" && ${lib.getExe greetings} && set -x FISH_TOP 1
    '';
  };
}
