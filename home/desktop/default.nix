{pkgs, ...}: {
  imports = [
    ./hyprland
    ./tofi
    ./waybar
  ];

  services.wl-clip-persist.enable = true;

  home.packages = with pkgs; [
    playerctl

    # notify
    libnotify
    dunst

    # wayland
    wl-clipboard
    wf-recorder
  ];
}
