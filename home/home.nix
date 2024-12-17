{ pkgs, inputs, nix-colors, ... }:

let
  colorscheme = nix-colors.colorSchemes.nord;
  # mkIfElse = p: yes: no: mkMerge [
  #   (mkIf p yes)
  #   (mkIf (!p) no)
  # ];
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

    ./lf.nix
    ./helix.nix
    ./alacritty.nix
    ./fish.nix
    ./zellij.nix
    ./nix-index.nix
    ./pass.nix
    ./hyprland.nix
  ];

  home = {
    username = "morga";
    homeDirectory = "/home/morga";

    shellAliases = {
      helix = "hx";
      ls = "eza -lh --group-directories-first --color=auto";
      cat = "bat";
      ssh = "env TERM=xterm-color ssh";
      cliRef = "curl -s 'http://pastebin.com/raw/yGmGiDQX' | less -i";
      page = "eval $PAGER";
      http = "xh";
    };

    packages = with pkgs; [
      # gui
      alacritty librewolf 
      libnotify dunst
      nerdfonts tofi

      # wayland
      wl-clipboard
    
      # cloud
      heroku 

      # security
      gnupg age pinentry

      # tui
      htop xh ncdu

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

  # GNOME config
  dconf = {
    enable = true;

    # dark theme
    settings."org/gnome/desktop/interfaces".color-scheme = "prefer-dark";

    # extensions
    settings."org/gnome/shell" = {
      disable-user-extensions = false;
      enabled-extensions = with pkgs.gnomeExtensions; [
        blur-my-shell.extensionUuid
        gsconnect.extensionUuid
        gpu-profile-selector.extensionUuid
      ];
    };
  };

  programs = {
    zellij = {
      enable = true;
      enableFishIntegration = true;
    };
  
    # enable git
    git = {
      enable = true;
      userName = "EmmChriss";
      userEmail = "emmchris@protonmail.com";
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

  services.ssh-agent.enable = true;
  services.gpg-agent.enable = true;

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

  home.pointerCursor = {
    gtk.enable = true;
    # x11.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 16;
  };

  gtk = {
    enable = true;

    theme = {
      package = pkgs.flat-remix-gtk;
      name = "Flat-Remix-GTK-Grey-Darkest";
    };

    iconTheme = {
      package = pkgs.adwaita-icon-theme;
      name = "Adwaita";
    };

    font = {
      name = "Sans";
      size = 11;
    };
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # DO NOT CHANGE
  home.stateVersion = "24.11";
}
