{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # get backlight when it changes by any means
    (writeShellApplication {
      name = "bar-backlight";
      runtimeInputs = [ entr bc ];
      text = ''
        echo /sys/class/backlight/amd*/brightness |\
        entr -ns bl
      '';
    })
  ];

  programs.waybar = {
    enable = true;
    systemd.enable = true;
    settings.mainBar = {
      layer = "top";
      position = "top";
      height = 24;
      spacing = 12;
      modules-left = ["hyprland/workspaces"];
      modules-center = ["hyprland/window"];
      modules-right = ["custom/backlight" "pulseaudio" "network" "cpu" "memory" "battery" "tray" "clock"];

      "hyprland/workspaces"= {
        persistent-workspaces= {
            "*" = 10;
        };
        disable-scroll = false;
        all-outputs = false;
        format = "{icon}";
        format-icons = {
            "1:web" = "";
            "2:code" = "";
            "3:term" = "";
            "4:work" = "";
            "5:music" = "";
            "6:docs" = "";
            urgent = "";
            empty = "⬤";
            active = "";
            default = "";
        };
      };

      "custom/backlight" = {
        exec = "bar-backlight";
        format = "{}% ";
      };

      tray.spacing = 10;

      clock.format = "{:%Y-%m-%d %H:%M}";

      cpu.format = "U:{usage}% L:{load} ";

      memory.format = "M:{percentage}% S:{swapPercentage}% F:{avail}G ";

      battery = {
        states = {
          good = 55;
          warning = 30;
          critical = 15;
        };
        format = "{time} {capacity}% {icon}";
        format-good = "{capacity}% {icon}";
        format-icons = ["" "" "" "" ""];
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
            headphones = "";
            handsfree = "";
            headset = "";
            phone = "";
            portable = "";
            car = "";
            default = ["" ""];
        };
      };
    };
    style = ./config/waybar.css;
  };
}
