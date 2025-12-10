{pkgs, ...}: {
  imports = [
    ./rbw
    ./direnv
    ./pager
    ./eza
    ./bat
    ./fish
    ./helix
    ./yazi
    ./zellij
    ./rustic
    ./mega
    ./rclone
    ./nix-index
  ];

  home.packages = with pkgs; [
    # security
    pinentry-all
    gnupg
    age
    agebox

    # system
    htop
    ncdu
    pulsemixer
    bluetuith

    # shell utils
    fd
    ripgrep
    tealdeer
    fzf
    ouch

    # media processing
    imagemagick
    ffmpeg

    # nix
    nh
    nix-tree
    comma
    steam-run-free
  ];
}
