{pkgs, ...}: {
  imports = [
    # ./gnome.mimeapps.nix
    ./pqiv
    ./alacritty
    ./librewolf
  ];

  services.mpris-proxy.enable = true;
  services.playerctld.enable = true;

  dbus.packages = with pkgs; [sushi nautilus nautilus-open-any-terminal papers];

  home.packages = with pkgs; [
    # default apps
    libreoffice-still
    loupe
    papers
    vlc

    nautilus
    sushi # nautilus file preview
    nautilus-open-any-terminal

    qbittorrent
    teams-for-linux
    popcorntime

    # creation
    typora
    godot_4
    aseprite
    gimp
    inkscape
    reaper
  ];

  xdg.mimeApps = {
    enable = true;
    defaultApplicationPackages = with pkgs; [
      loupe
      papers
      nautilus
      vlc
      librewolf
      qbittorrent
      inkscape
    ];
  };

  # XDG default apps
  # xdg.mimeApps = let
  #   browser = "librewolf.desktop";
  #   files = "com.system76.CosmicFiles.desktop";
  #   docs = "org.gnome.Papers.desktop";
  #   videos = "vlc.desktop";
  # in {
  #   enable = true;
  #   associations.added = {
  #     "x-scheme-handler/msteams" = ["teams-for-linux.desktop"];
  #   };
  #   associations.removed = {};
  #   defaultApplications = {
  #     # web
  #     "x-scheme-handler/http" = [browser];
  #     "x-scheme-handler/https" = [browser];
  #     "x-scheme-handler/mailto" = [browser];
  #     "x-scheme-handler/ftp" = [browser];
  #     "x-scheme-handler/chrome" = [browser];
  #     "application/xhtml+xml" = [browser];
  #     "text/html" = [browser];

  #     # file types
  #     "application/pdf" = [
  #       docs
  #       browser
  #     ];
  #   };
  # };

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
