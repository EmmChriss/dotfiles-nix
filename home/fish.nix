{ pkgs, ... }:

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
      functions = {
        # disable greeting
        fish_greeting = "";
      };
      interactiveShellInit = builtins.readFile ./config/config.fish;
    };
}
