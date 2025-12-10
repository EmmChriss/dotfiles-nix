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
}
