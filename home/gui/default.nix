{pkgs, ...}: {
  imports = [
    ./pqiv
    ./alacritty
    ./librewolf
  ];

  services.mpris-proxy.enable = true;
  services.playerctld.enable = true;

  home.packages = with pkgs; [
    qbittorrent
    teams-for-linux
    file-roller
    popcorntime
    vlc
    evince

    # creation
    typora
    godot_4
    aseprite
    gimp
    inkscape
    reaper
  ];
}
