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

    # fallback
    ungoogled-chromium
  ];

  xdg.configFile."chromium-flags.conf".text = ''
    --disable-gpu-driver-bug-workarounds
    --ignore-gpu-blocklist
    --new-canvas-2d-api
    --enable-accelerated-2d-canvas
    --ozone-platform=wayland
    --enable-features=WaylandWindowDecorations
    --enable-gpu-rasterization
    --enable-gpu-compositing
    --enable-zero-copy
    --enable-raw-draw
    --enable-webrtc-pipewire-capturer
    --enable-features=WebRTCPipeWireCapturer
    --enable-features=VaapiVideoDecode
    --enable-features=VaapiVideoDecodeLinuxGL
    --use-gl=angle
    --use-angle=gl

    --enable-parallel-downloading
    --process-per-site
    --enable-native-notifications

    # This is workaround for the bug:
    # https://github.com/hyprwm/Hyprland/discussions/11961
    # It must be removed once the bug is fixed and chrome doesn't crash when moved between monitors.
    --disable-features=WaylandWpColorManagerV1
  '';

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
