{ pkgs, config, lib, inputs, outputs, nix-colors, ... }:

let colorscheme = nix-colors.colorSchemes.nord;
in
{
  # You can import other home-manager modules here
  imports = [
    # If you want to use modules your own flake exports (from modules/home-manager):
    # outputs.homeManagerModules.example

    # Or modules exported from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModules.default

    # You can also split up your configuration and import pieces of it here:
    # ./nvim.nix

    ./nix-index.nix
    ./pass.nix
    ./hyprland.nix
  ];

  home = {
    username = "morga";
    homeDirectory = "/home/morga";

    packages = with pkgs; [
      # gui
      alacritty librewolf 
      libnotify dunst
    
      # cloud
      heroku 

      # security
      gnupg age

      # tui
      helix zellij fish lf
      htop

      # cli
      ripgrep tealdeer fzf
      bat atool grc
      ffmpeg gitui eza

      unzip 
      grim slurp slop
      imagemagick libnotify
      git python3 lua zig 
      mpv firefox pqiv
      screen
      wf-recorder anki-bin 
    ];
  };

  programs = {
    # enable git
    git = {
      enable = true;
      userName = "EmmChriss";
      userEmail = "emmchris@protonmail.com";
    };
  
    # enable fish shell
    fish = {
      enable = true;
      interactiveShellInit = builtins.readFile ./config.fish;
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
    };

    # bat: cat replacement
    bat = {
      enable = true;
      config.theme = "base16";
    };

    # direnv: load-unload .envrc and .env files
    direnv = {
      enable = true;
      nix-direnv.enable = true;
      config.whitelist.prefix = [ "/home/morga/Project" ];
    };
  };

  # enable hyprand
  wayland.windowManager.hyprland = {
    enable = true;
    systemd.variables = ["--all"];
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
  };

  services.ssh-agent.enable = true;

  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      documents = "$HOME/Documents";
      download = "$HOME/Downloads";
      videos = "$HOME/Media/Videos";
      music = "$HOME/Media/Music";
      pictures = "$HOME/Media/Pictures";
      desktop = "$HOME/Desktop";
    };
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # DO NOT CHANGE
  home.stateVersion = "24.11";
}
