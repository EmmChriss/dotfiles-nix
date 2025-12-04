{pkgs, ...}: {
  home.packages = with pkgs; [
    # get backlight when it changes by any means
    # uses generic backlight script defined in ./scripts.nix
    (writeShellApplication {
      name = "bar-backlight";
      runtimeInputs = [entr];
      text = ''
        echo /sys/class/backlight/amd*/brightness |\
        entr -ns bl
      '';
    })
  ];

  programs.waybar = {
    enable = true;
    systemd = {
      enable = true;
      # only for hyprland
      target = "wayland-session@Hyprland.target";
    };
    settings.mainBar = {
      layer = "top";
      position = "top";
      height = 24;
      spacing = 12;
      modules-left = [
        "hyprland/workspaces"
        "hyprland/window"
      ];
      modules-right = [
        "custom/backlight"
        "pulseaudio"
        "network"
        "cpu"
        "memory"
        "battery"
        "tray"
        "clock"
      ];

      "hyprland/workspaces" = {
        persistent-workspaces = {
          "*" = 10;
        };
        disable-scroll = false;
        all-outputs = false;
        format = " {icon} {windows}";
        format-window-separator = " ";
        window-rewrite-default = "";
        window-rewrite = {
          "title<.*youtube.*>" = "";
          "class<librewolf>" = "";
          "title<.*github.*>" = "";
          "alacritty" = "";
          "title<Zellij.*>" = "";
        };
      };

      "custom/backlight" = {
        exec = "bar-backlight";
        format = "{}% ";
      };

      tray.spacing = 10;

      clock.format = "{:%Y-%m-%d %H:%M}";

      cpu.format = "U:{usage}% L:{load} ";

      memory = {
        format = "F:{avail}G ";
        interval = 1;
        states = {
          good = 70;
          warning = 85;
          critical = 90;
        };
      };

      battery = {
        states = {
          good = 55;
          warning = 30;
          critical = 15;
        };
        interval = 10;
        format = "{capacity}% {icon}";
        format-discharging = "{time} {capacity}% {icon}";
        tooltip-format = "{time} {power}W";
        format-icons = [
          ""
          ""
          ""
          ""
          ""
        ];
      };

      network = {
        format-wifi = "{essid} ({signalStrength}%) ";
        format-ethernet = "{ifname} ";
        format-disconnected = "Disconnected ⚠";
      };

      pulseaudio = {
        format = "{volume}% {icon}";
        format-bluetooth = "{volume}% {icon}";
        format-muted = "";
        format-icons = {
          headphone = "";
          hands-free = "";
          headset = "";
          phone = "";
          portable = "";
          car = "";
          default = [
            ""
            ""
          ];
        };
      };
    };
    style = ./config/waybar.css;
  };
}
