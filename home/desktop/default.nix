{pkgs, ...}: {
  imports = [
    ./hyprland
    ./tofi
    ./waybar
  ];

  home.packages = with pkgs; [
    playerctl

    # notify
    libnotify
    dunst

    # wayland
    wl-clipboard
    wf-recorder
  ];

  # XDG default apps
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
      "application/pdf" = [
        "evince.desktop"
        "firefox.desktop"
      ];
      "video/*" = ["vlc.desktop"];

      "inode/directory" = ["thunar.desktop"];
      "image/*" = ["pqiv.desktop"];

      "application/zip" = ["thunar.desktop"];
    };
  };

  # theme
  dconf = {
    enable = true;
    settings."org/gnome/desktop/interfaces".color-scheme = "prefer-dark";
  };

  home.pointerCursor = {
    gtk.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 16;
  };

  gtk = {
    enable = true;

    # cursorTheme = {
    #   name = "capitaine-cursors-white";
    #   package = pkgs.capitaine-cursors;
    # };

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
}
