{pkgs, ...}: {
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
    ./vcs.nix
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
      # gui
      alacritty
      librewolf
      ungoogled-chromium
      libnotify
      dunst
      tofi
      reaper
      qbittorrent
      nerd-fonts.iosevka-term
      teams-for-linux
      file-roller
      popcorntime
      typora
      vlc
      gimp
      inkscape
      evince

      # gamedev
      godot_4
      libresprite
      aseprite

      # wayland
      wl-clipboard
      grim
      slurp
      libnotify
      wf-recorder # screen recorder on wayland
      playerctl
      swappy

      # cloud
      heroku
      flyctl
      megacmd

      # security
      gnupg
      age
      pinentry

      # tui
      htop
      xh
      gitui
      ncdu
      pulsemixer
      bluetuith

      # cli
      ripgrep
      tealdeer
      fzf
      bat
      grc
      eza
      ouch
      imagemagick
      ffmpeg

      # nix
      nh
      manix
      nix-tree
      comma
      steam-run-free

      # dev tools
      bun
      nodejs
      docker-compose
      psmisc
      postgresql
      pgcli
      git
      python3
      lua
      zig
      uv
      rustup
      clang
      pkg-config
      openssl

      # dbeaver breaks on Hyprland default backend, use GDK_BACKEND=x11
      # TODO: maybe make this an overlay
      (symlinkJoin {
        name = "dbeaver";
        paths = [dbeaver-bin];
        buildInputs = [makeWrapper];
        postBuild = ''
          rm $out/bin/dbeaver
          makeWrapper ${dbeaver-bin}/bin/dbeaver $out/bin/dbeaver \
            --set GDK_BACKEND x11

          rm $out/share/applications/dbeaver.desktop
          substitute ${dbeaver-bin}/share/applications/dbeaver.desktop $out/share/applications/dbeaver.desktop \
            --replace-fail ${dbeaver-bin}/bin/dbeaver $out/bin/dbeaver
        '';
      })
    ];
  };

  # default packages
  xdg.mimeApps = {
    enable = true;
    associations.added = {
      "x-scheme-handler/msteams" = ["teams-for-linux.desktop"];
    };
    associations.removed = {};
    defaultApplications = {
      "x-scheme-handler/msteams" = ["teams-for-linux.desktop"];
      "x-scheme-handler/http" = ["firefox.desktop"];
      "x-scheme-handler/https" = ["firefox.desktop"];
      "x-scheme-handler/mailto" = ["firefox.desktop"];
      "text/html" = ["firefox.desktop"];
      "application/pdf" = ["evince.desktop" "firefox.desktop"];
      "video/*" = ["vlc.desktop"];

      "inode/directory" = ["thunar.desktop"];
      "image/*" = ["pqiv.desktop"];

      "application/zip" = ["thunar.desktop"];
    };
  };

  # GNOME config
  dconf = {
    enable = true;

    # dark theme
    settings."org/gnome/desktop/interfaces".color-scheme = "prefer-dark";
  };

  programs = {
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
        whitelist.prefix = ["~/Project"];
        global = {
          hide_env_diff = true;
          load_dotenv = true;
          strict_env = true;
        };
      };
    };
  };

  systemd.user.services.megacmd = {
    Unit = {Description = "Sync user directories to MEGA";};
    Service = {
      ExecStart = "${pkgs.megacmd}/bin/mega-cmd-server";
      Restart = "always";
    };
    Install.WantedBy = ["default.target"];
  };

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

    cursorTheme = {
      name = "capitaine-cursors-white";
      package = pkgs.capitaine-cursors;
    };

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

  qt = {
    enable = true;
    platformTheme.name = "gtk";
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # DO NOT CHANGE
  home.stateVersion = "24.11";
}
