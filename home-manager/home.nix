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

      # cli
      helix zellij ripgrep 
      tealdeer htop fzf
      pass bat atool git
      ffmpeg gitui 

      unzip 
      grim slurp slop
      imagemagick libnotify
      git python3 lua zig 
      mpv firefox pqiv
      screen
      wf-recorder anki-bin 
    ];
  };

  # enable hyprand and configure it
  wayland.windowManager.hyprland = {
    enable = true;
    systemd.variables = ["--all"];
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
  };

  programs.git = {
    enable = true;
    userName = "EmmChriss";
    userEmail = "emmchris@protonmail.com";
  };

  xdg.userDirs = {
    enable = true;
    documents = "$HOME/Documents";
    download = "$HOME/Downloads";
    videos = "$HOME/Media/Videos";
    music = "$HOME/Media/Music";
    pictures = "$HOME/Media/Pictures";
    desktop = "$HOME/Desktop";
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # DO NOT CHANGE
  home.stateVersion = "24.11";
}
