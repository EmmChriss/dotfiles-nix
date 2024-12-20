{ pkgs, lib, config, ... }:

# TODO: look into hasPackage. Problem: some packages do not get placed in 
#   home.packages, but instead are activated with programs.*.enable, or
#   equivalent. 
let
  inherit (lib) mkIf;
  packageNames = map (p: p.pname or p.name or null) config.home.packages;
  hasPackage = name: lib.any (x: x == name) packageNames;
in
{
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
      shellAbbrs = {
        tmux = mkIf (hasPackage "zellij") "zellij";
        bt = "bluetoothctl";
        gs = "git status";
        gd="git diff";
        gl="git log";
        gmv="git mv";
        grm="git rm";
      };
      shellAliases = {
        # use yazi instead of lf
        lf = "y";
      };
      functions = {
        # disable greeting
        fish_greeting = "";
      };
      interactiveShellInit = builtins.readFile ./config/config.fish;
    };
}
