{
  lib,
  pkgs,
  ...
}: let
  # get backlight when it changes by any means
  # uses generic backlight script defined in ./scripts.nix
  bar-backlight = pkgs.writeShellApplication {
    name = "bar-backlight";
    runtimeInputs = [pkgs.entr];
    text = ''
      echo /sys/class/backlight/amd*/brightness |\
      entr -ns bl
    '';
  };

  bar-lang = pkgs.writeShellApplication {
    name = "bar-lang";
    runtimeInputs = [pkgs.hyprland pkgs.socat];
    text = ''
      socat - UNIX-CONNECT:"$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" |\
      grep -E '^activelayout>>' --line-buffered |\
      cut -d, -f2
    '';
  };

  bar-wg = pkgs.writeShellApplication {
    name = "bar-wg";
    runtimeInputs = [pkgs.networkmanager];
    text = ''
      export yes=VPN
      export no="VPN't"
      # shellcheck disable=SC2016
      nmcli m |\
      xargs -I{} -P1 sh -c 'nmcli c | grep -q wireguard && echo "$yes" || echo "$no"'
    '';
  };
in {
  home.packages = [bar-lang];

  programs.waybar = {
    enable = true;
    systemd = {
      enable = true;
      target = "graphical-session.target";
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
        "custom/vpn"
        "network"
        "cpu"
        "memory"
        "battery"
        "tray"
        # "custom/language"
        "hyprland/language"
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

      "hyprland/window" = {
        separate-outputs = true;
      };

      "custom/backlight" = {
        exec = lib.getExe bar-backlight;
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

      "custom/vpn" = {
        exec = lib.getExe bar-wg;
        format = "{}";
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

      "hyprland/language" = {
        format-en = "US";
        format-hu = "HU";
        format-ro = "RO";
      };

      "custom/language" = {
        exec = lib.getExe bar-lang;
        format = "{:.3}";
      };
    };
    style = ./style.css;
  };
}
