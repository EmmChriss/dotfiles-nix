{...}: {
  imports = [
    ./config.nix
    ./uwsm.nix
    ./keybinds.nix
  ];

  # enable hyprland
  # WARN: do not set any additional options, use the Hyprland that is installed system-wide
  wayland.windowManager.hyprland = {
    enable = true;
    # NOTE: in UWSM-managed environments, this is a conflict
    systemd.enable = false;
    configType = "lua";
    extraConfig = builtins.readFile ./config.lua;
  };
}
