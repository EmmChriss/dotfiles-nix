{ pkgs, ... }:

{
  # You can import other home-manager modules here
  imports = [
    # If you want to use modules your own flake exports (from modules/home-manager):
    # outputs.homeManagerModules.example

    # Or modules exported from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModules.default

    # You can also split up your configuration and import pieces of it here:
    # ./nvim.nix

    ./yazi.nix
    ./pqiv.nix
    ./tofi.nix
    ./scripts.nix
    ./waybar.nix
    ./helix.nix
    ./alacritty.nix
    ./fish.nix
    ./zellij.nix
    ./nix-index.nix
    ./pass.nix
    ./hyprland.nix
    ./rustic.nix
  ];

  home = {
    username = "morga";
    homeDirectory = "/home/morga";

    sessionVariables = {
      EDITOR = "hx";
      VISUAL = "hx";
      PAGER = "less";
      TERMINAL = "alacritty";
      BROWSER = "librewolf";

      # configure tui apps
      LESS = "-SIRNs --incsearch";
      BAT_THEME = "TwoDark";

      # save all rust builds to same place
      CARGO_TARGET_DIR = "/home/morga/.cache/target";
    };

    sessionPath = [
      "$HOME/.cargo/bin"
    ];

    shellAliases = {
      # EDITOR
      helix = "hx";

      # SHELL tools
      ls = "eza -lh --group-directories-first --color=auto";
      cat = "bat";
      page = "eval $PAGER";

      # network
      bt = "bluetoothctl";
      ssh = "env TERM=xterm-color ssh";
      http = "xh";

      # utility
      cliRef = "curl -s 'http://pastebin.com/raw/yGmGiDQX' | less -i";

      # when in doubt
      atool = "echo Did you mean ouch compress/decompress'?'";
      apack = "echo Did you mean ouch compress'?'";
      aunpack = "echo Did you mean ouch decompress'?'";

      # switched from lf to yazi
      lf = "y";

      # switched from tmux to zellij
      tmux = "zellij";
    };

    packages = with pkgs; [
      # uni
      protege-distribution

      prelockd
      
      # gui
      alacritty librewolf ungoogled-chromium
      libnotify dunst tofi
      (nerdfonts.override { fonts = ["IosevkaTerm"]; })
      teams-for-linux file-roller
      popcorntime

      # wayland
      wl-clipboard grim
      slurp libnotify
      wf-recorder # screen recorder on wayland
      playerctl swappy
    
      # cloud
      heroku flyctl megacmd

      # security
      gnupg age pinentry

      # tui
      htop xh gitui ncdu
      pulsemixer bluetuith
      
      # cli
      ripgrep tealdeer fzf
      bat grc ffmpeg eza
      ouch imagemagick
      
      # nix
      nh manix nix-du
      nix-tree comma
      steam-run-free # just run some ld-loading program 

      # dev tools
      pnpm nodejs docker-compose
      psmisc postgresql pgcli
      git python3 lua zig uv

      # rust
      (rust-bin.stable.latest.default.override {
        extensions = [ "rustc" "rust-src" "rustfmt" "cargo" "clippy" "rust-analyzer" ];
        targets = [ "wasm32-unknown-unknown" ];
      })

      # dbeaver breaks on Hyprland default backend, use GDK_BACKEND=x11
      # TODO: overwrite/create dbeaver.desktop
      # (let wrapped = writeShellScriptBin "dbeaver" "GDK_BACKEND=x11 exec ${dbeaver-bin}/bin/dbeaver";
      # in pkgs.symlinkJoin {
      #   name = "dbeaver";
      #   paths = [wrapped dbeaver-bin]; 
      # })
      dbeaver-bin
    ];
  };

  # GNOME config
  dconf = {
    enable = true;

    # dark theme
    settings."org/gnome/desktop/interfaces".color-scheme = "prefer-dark";
  };

  programs = {
    # enable git
    git = {
      enable = true;

      # git large file support
      lfs.enable = true;

      # git diff highlighter
      delta = {
        enable = true;
        options = {
          navigate = true;
          side-by-side = true;
        };
      };
      
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
      config = {
        whitelist.prefix = [ "~/Project" ];
        global = {
          hide_env_diff = true;
          load_dotenv = true;
          strict_env = true;
        };
      };
    };
  };

  systemd.user.services.megacmd = {
    Unit = { Description = "Sync user directories to MEGA"; };
    Service = {
      ExecStart = "${pkgs.megacmd}/bin/mega-cmd-server";
      Restart = "always";
    };
    Install.WantedBy = ["default.target"];
  };

  services.ssh-agent.enable = true;
  services.gpg-agent.enable = true;
  services.mpris-proxy.enable = true;
  services.playerctld.enable = true;
  services.cliphist.enable = true;

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
