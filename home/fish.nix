{ pkgs, lib, config, ... }:

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
        helix = mkIf (hasPackage "helix") "hx";
        ls = mkIf (hasPackage "eza") "eza -lh --group-directories-first --color=auto";
        cat = mkIf (hasPackage "bat") "bat";
        ssh = "env TERM=xterm-color ssh";
        cliRef = "curl -s 'http://pastebin.com/raw/yGmGiDQX' | less -i";
        page = "eval $PAGER";
        http = "xh";
      };
      functions = {
        # disable greeting
        fish_greeting = "";
      };
      interactiveShellInit = builtins.readFile ./config.fish;
    };
}
