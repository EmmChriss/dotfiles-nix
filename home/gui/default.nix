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
    mpv
    calibre
    jellyfin-media-player
    zoom

    nautilus
    sushi # nautilus file preview
    nautilus-open-any-terminal

    qbittorrent
    teams-for-linux
    popcorntime

    # creation
    typora
    godot
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
      mpv
      librewolf
      qbittorrent
      inkscape
      teams-for-linux
      zoom
    ];
  };

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
