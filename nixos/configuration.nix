{
  lib,
  pkgs,
  inputs,
  outputs,
  ...
}:
# Template: https://github.com/Misterio77/nix-starter-configs; standard variant
{
  # You can import other nixos modules here
  imports = [
    # if you wanto use modules your own flake exports (from modules/nixos)
    # outputs.nixosModules.example

    # Or modules from other flakes (such as nixos-hardware):
    # inputs.hardware.nixosModules.common-cpu-am
    # inputs.hardware.nixosModules.common-ssd

    # import entire laptop config
    inputs.nixos-hardware.nixosModules.lenovo-ideapad-15arh05

    # enable amd-pstate
    inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate

    # Import your generated (nixos-generate-config) hardware configuration
    ./hardware-configuration.nix

    # Deduplicate files system-wide
    outputs.nixosModules.duperemove

    # Configure ProtonVPN
    ./protonvpn.nix
  ];

  # remove unnecessary preinstalled packages
  environment.defaultPackages = [];

  # Nix settings
  nix = {
    settings = {
      auto-optimise-store = true;
      trusted-users = ["morga"];
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 7d";
    };
  };

  # Boot
  boot = {
    tmp.cleanOnBoot = true;
    loader = {
      timeout = 1;
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot/efi";
      };
      grub = {
        efiSupport = true;
        device = "nodev";
      };
    };
  };

  # Networking
  networking.hostName = "morga";
  networking = {
    # enable NetworkManager
    networkmanager = {
      enable = true;
      wifi.powersave = true;

      dns = "none";
    };

    useDHCP = false;
    dhcpcd.enable = false;
    nameservers = [
      "1.1.1.1"
      "1.0.0.1"
      "8.8.8.8"
      "8.8.4.4"
    ];
  };

  # Locale
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # Enable touchpad support
  services.libinput.enable = true;

  # Hardware
  hardware = {
    enableRedistributableFirmware = true;

    bluetooth = {
      enable = true;

      # enables fetchin bluetooth headset battery status
      settings.General = {
        FastConnectable = true;
        Experimental = true;
      };
    };
  };

  environment.systemPackages = [
    pkgs.wireguard-tools

    # Power monitor with system access
    # NOTE: powertop can be started as a service, but it messes with my wireless
    # mouse, and I didn't look into how to disable just that
    # powerManagement.powertop.enable = true;
    pkgs.powertop
  ];

  # Audio
  # see NixOS Wiki:Audio
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;

    wireplumber.extraConfig.bluetooth-enhancements = {
      "monitor.bluez.properties" = {
        "bluez5.enable-hw-volume" = true;
        "bluez5.enable-sbc-xq" = true;
        "bluez5.enable-msbc" = true;
      };
      "wireplumber-settings" = {
        # do not switch to headset profile ever
        "bluetooth.autoswitch-to-headset-profile" = false;
      };
    };
  };

  # Sudo
  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
    extraConfig = ''
      Defaults env_keep += "http_proxy https_proxy"
      Defaults env_keep += "HTTP_PROXY HTTPS_PROXY"
      Defaults env_keep += "ftp_proxy FTP_PROXY"
      Defaults env_keep += "EDITOR VISUAL"
    '';
  };
  security.protectKernelImage = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.morga = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
      "docker"
      "podman"
      "adbusers"
    ];
  };

  # Instead of setting as login shell, run fish immediately when bash starts
  # Also switch to fish on first nix-shell
  # See: https://nixos.wiki/wiki/Fish
  programs.fish.enable = true;
  programs.bash = {
    interactiveShellInit = ''
      if test -z ''${BASH_EXECUTION_STRING} &&\
        test $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" ||\
        test -n "$IN_NIX_SHELL" && test -z "$BASH_NIX_SHELL_TOP"
      then
        test -n "$IN_NIX_SHELL" && export BASH_NIX_SHELL_TOP=1
        shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
        exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
      fi
    '';
  };

  # Display manager
  services.displayManager.gdm = {
    enable = true;
    wayland = true;
  };

  # Automatic timezone updates
  services.tzupdate = {
    enable = true;
    timer.enable = true;
  };

  # Window manager
  # NOTE: hyprland is installed here, but configured in home-manager
  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };

  hardware.graphics.enable = true;

  # Nvidia
  hardware.nvidia = {
    # creates specialization called "battery-saver"
    primeBatterySaverSpecialisation = true;

    # modesetting is usually needed
    modesetting.enable = true;
    nvidiaPersistenced = true;
    nvidiaSettings = false;
    powerManagement = {
      enable = true;
      finegrained = true;
    };
    prime = {
      reverseSync.enable = true;
      sync.enable = false;
    };
  };

  # Gaming mode
  specialisation.gaming.configuration = {
    hardware.nvidia = {
      prime = {
        reverseSync.enable = lib.mkForce false;
        sync.enable = lib.mkForce true;
        offload = {
          enable = lib.mkForce false;
          enableOffloadCmd = lib.mkForce false;
        };
      };
      powerManagement.finegrained = lib.mkForce false;
    };

    # mount appdata under primary wine prefix
    fileSystems."/home/morga/.wine/drive_c/users/morga/AppData" = {
      device = "/mnt/win/Users/Morga/AppData";
      depends = [
        "/mnt/win"
      ];
      fsType = "none";
      options = [
        "bind"
        "rw"
      ];
    };

    programs.gamescope = {
      enable = true;
      capSysNice = true;
      args = ["--rt"];
      env =
        # for Prime render offload on Nvidia laptops.
        # Also requires `hardware.nvidia.prime.offload.enable`.
        {
          __NV_PRIME_RENDER_OFFLOAD = "1";
          __VK_LAYER_NV_optimus = "NVIDIA_only";
          __GLX_VENDOR_LIBRARY_NAME = "nvidia";
        };
    };

    programs.gamemode.enable = true;

    environment.systemPackages = with pkgs; let
      # overwrite bwrap to get all caps
      # then use that bwrap in lutris
      hackedLutris = let
        hackedPkgs = pkgs.extend (final: prev: {
          buildFHSEnv = args:
            prev.buildFHSEnv (args
              // {
                extraBwrapArgs =
                  (args.extraBwrapArgs or [])
                  ++ [
                    "--cap-add ALL"
                  ];
              });
        });
      in
        hackedPkgs.lutris;
    in [
      # monitor fps and stuff
      mangohud
      # install proton-ge and wine-ge
      protonup-ng
      # launchers
      hackedLutris
      heroic
      # wineprefix manager
      bottles
    ];

    environment.sessionVariables = {
      STEAM_EXTRA_COMPAT_TOOLS_PATHS = "\${HOME}/.steam/root/compatibilitytools.d";
    };

    services.udev.extraRules = ''
      # Valve USB devices
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="28de", MODE="0660", TAG+="uaccess"

      # Steam Controller udev write access
      KERNEL=="uinput", SUBSYSTEM=="misc", TAG+="uaccess", OPTIONS+="static_node=uinput"

      # Valve HID devices over USB hidraw
      KERNEL=="hidraw*", ATTRS{idVendor}=="28de", MODE="0660", TAG+="uaccess"

      # Valve HID devices over bluetooth hidraw
      KERNEL=="hidraw*", KERNELS=="*28DE:*", MODE="0660", TAG+="uaccess"

      # DualShock 3 over USB hidraw
      KERNEL=="hidraw*", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="0268", MODE="0660", TAG+="uaccess"

      # DualShock 3 over bluetooth hidraw
      KERNEL=="hidraw*", KERNELS=="*054C:0268*", MODE="0660", TAG+="uaccess"

      # DualShock 4 over USB hidraw
      KERNEL=="hidraw*", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="05c4", MODE="0660", TAG+="uaccess"

      # DualShock 4 wireless adapter over USB hidraw
      KERNEL=="hidraw*", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="0ba0", MODE="0660", TAG+="uaccess"

      # DualShock 4 Slim over USB hidraw
      KERNEL=="hidraw*", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="09cc", MODE="0660", TAG+="uaccess"

      # DualShock 4 over bluetooth hidraw
      KERNEL=="hidraw*", KERNELS=="*054C:05C4*", MODE="0660", TAG+="uaccess"

      # DualShock 4 Slim over bluetooth hidraw
      KERNEL=="hidraw*", KERNELS=="*054C:09CC*", MODE="0660", TAG+="uaccess"

      # PS5 DualSense controller over USB hidraw
      KERNEL=="hidraw*", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="0ce6", MODE="0660", TAG+="uaccess"

      # PS5 DualSense controller over bluetooth hidraw
      KERNEL=="hidraw*", KERNELS=="*054C:0CE6*", MODE="0660", TAG+="uaccess"

      # Sony DualSense Edge Wireless-Controller over bluetooth hidraw
      KERNEL=="hidraw*", KERNELS=="*054C:0DF2*", MODE="0660", TAG+="uaccess"

      # Sony DualSense Edge Wireless-Controller over USB hidraw
      KERNEL=="hidraw*", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="0df2", MODE="0660", TAG+="uaccess"

      # Nintendo Switch Pro Controller over USB hidraw
      KERNEL=="hidraw*", ATTRS{idVendor}=="057e", ATTRS{idProduct}=="2009", MODE="0660", TAG+="uaccess"

      # Nintendo Switch Pro Controller over bluetooth hidraw
      KERNEL=="hidraw*", KERNELS=="*057E:2009*", MODE="0660", TAG+="uaccess"

      # Nintendo Switch Joy-Con (L/R)
      KERNEL=="hidraw*", KERNELS=="*057E:200[67]*", MODE="0660", TAG+="uaccess"

      # PDP Faceoff Wired Pro Controller for Nintendo Switch
      KERNEL=="hidraw*", ATTRS{idVendor}=="0e6f", ATTRS{idProduct}=="0180", MODE="0660", TAG+="uaccess"

      # PDP Faceoff Deluxe+ Audio Wired Pro Controller for Nintendo Switch
      KERNEL=="hidraw*", ATTRS{idVendor}=="0e6f", ATTRS{idProduct}=="0184", MODE="0660", TAG+="uaccess"

      # PDP Wired Fight Pad Pro for Nintendo Switch
      KERNEL=="hidraw*", ATTRS{idVendor}=="0e6f", ATTRS{idProduct}=="0185", MODE="0660", TAG+="uaccess"

      # PowerA Wired Controller for Nintendo Switch
      KERNEL=="hidraw*", ATTRS{idVendor}=="20d6", ATTRS{idProduct}=="a711", MODE="0660", TAG+="uaccess"
      KERNEL=="hidraw*", ATTRS{idVendor}=="20d6", ATTRS{idProduct}=="a712", MODE="0660", TAG+="uaccess"
      KERNEL=="hidraw*", ATTRS{idVendor}=="20d6", ATTRS{idProduct}=="a713", MODE="0660", TAG+="uaccess"

      # PowerA Wireless Controller for Nintendo Switch we have to use
      # ATTRS{name} since VID/PID are reported as zeros. We use /bin/sh
      # instead of udevadm directly becuase we need to use '*' glob at the
      # end of "hidraw" name since we don't know the index it'd have.
      #
      KERNEL=="input*", ATTRS{name}=="Lic Pro Controller", RUN{program}+="/bin/sh -c 'udevadm test-builtin uaccess /sys/%p/../../hidraw/hidraw*'"

      # Afterglow Deluxe+ Wired Controller for Nintendo Switch
      KERNEL=="hidraw*", ATTRS{idVendor}=="0e6f", ATTRS{idProduct}=="0188", MODE="0660", TAG+="uaccess"

      # Nacon PS4 Revolution Pro Controller
      KERNEL=="hidraw*", ATTRS{idVendor}=="146b", ATTRS{idProduct}=="0d01", MODE="0660", TAG+="uaccess"

      # Razer Raiju PS4 Controller
      KERNEL=="hidraw*", ATTRS{idVendor}=="1532", ATTRS{idProduct}=="1000", MODE="0660", TAG+="uaccess"

      # Razer Raiju 2 Tournament Edition
      KERNEL=="hidraw*", ATTRS{idVendor}=="1532", ATTRS{idProduct}=="1007", MODE="0660", TAG+="uaccess"

      # Razer Panthera EVO Arcade Stick
      KERNEL=="hidraw*", ATTRS{idVendor}=="1532", ATTRS{idProduct}=="1008", MODE="0660", TAG+="uaccess"

      # Razer Raiju PS4 Controller Tournament Edition over bluetooth hidraw
      KERNEL=="hidraw*", KERNELS=="*1532:100A*", MODE="0660", TAG+="uaccess"

      # Razer Raiju Ultimate over USB
      KERNEL=="hidraw*", ATTRS{idVendor}=="1532", ATTRS{idProduct}=="1004", MODE="0660", TAG+="uaccess"

      # Razer Raiju Ultimate over PC Bluetooth
      KERNEL=="hidraw*", KERNELS=="*1532:1009*", MODE="0660", TAG+="uaccess"

      # Razer Panthera Arcade Stick
      KERNEL=="hidraw*", ATTRS{idVendor}=="1532", ATTRS{idProduct}=="0401", MODE="0660", TAG+="uaccess"

      # Razer Wolverine V2 Pro in wired PS5 mode
      KERNEL=="hidraw*", ATTRS{idVendor}=="1532", ATTRS{idProduct}=="100b", MODE="0660", TAG+="uaccess"

      # Mad Catz - Street Fighter V Arcade FightPad PRO
      KERNEL=="hidraw*", ATTRS{idVendor}=="0738", ATTRS{idProduct}=="8250", MODE="0660", TAG+="uaccess"

      # Mad Catz - Street Fighter V Arcade FightStick TE S+
      KERNEL=="hidraw*", ATTRS{idVendor}=="0738", ATTRS{idProduct}=="8384", MODE="0660", TAG+="uaccess"

      # Brooks Universal Fighting Board
      KERNEL=="hidraw*", ATTRS{idVendor}=="0c12", ATTRS{idProduct}=="0c30", MODE="0660", TAG+="uaccess"

      # EMiO Elite Controller for PS4
      KERNEL=="hidraw*", ATTRS{idVendor}=="0c12", ATTRS{idProduct}=="1cf6", MODE="0660", TAG+="uaccess"

      # ZeroPlus P4 (hitbox)
      KERNEL=="hidraw*", ATTRS{idVendor}=="0c12", ATTRS{idProduct}=="0ef6", MODE="0660", TAG+="uaccess"

      # HORI RAP4
      KERNEL=="hidraw*", ATTRS{idVendor}=="0f0d", ATTRS{idProduct}=="008a", MODE="0660", TAG+="uaccess"

      # HORI Alpha for PS5 (PS5 Mode)
      KERNEL=="hidraw*", ATTRS{idVendor}=="0f0d", ATTRS{idProduct}=="0184", MODE="0660", TAG+="uaccess"

      # HORI Alpha for PS5 (PS4 Mode)
      KERNEL=="hidraw*", ATTRS{idVendor}=="0f0d", ATTRS{idProduct}=="011c", MODE="0660", TAG+="uaccess"

      # HORI Alpha for PS5 (PC Mode)
      KERNEL=="hidraw*", ATTRS{idVendor}=="0f0d", ATTRS{idProduct}=="011e", MODE="0660", TAG+="uaccess"

      # HORIPAD 4 FPS
      KERNEL=="hidraw*", ATTRS{idVendor}=="0f0d", ATTRS{idProduct}=="0055", MODE="0660", TAG+="uaccess"

      # HORIPAD 4 FPS Plus
      KERNEL=="hidraw*", ATTRS{idVendor}=="0f0d", ATTRS{idProduct}=="0066", MODE="0660", TAG+="uaccess"

      # HORIPAD for Nintendo Switch
      KERNEL=="hidraw*", ATTRS{idVendor}=="0f0d", ATTRS{idProduct}=="00c1", MODE="0660", TAG+="uaccess"

      # HORIPAD mini 4
      KERNEL=="hidraw*", ATTRS{idVendor}=="0f0d", ATTRS{idProduct}=="00ee", MODE="0660", TAG+="uaccess"

      # HORIPAD STEAM
      KERNEL=="hidraw*", ATTRS{idVendor}=="0f0d", ATTRS{idProduct}=="01ab", MODE="0660", TAG+="uaccess"

      # Armor Armor 3 Pad PS4
      KERNEL=="hidraw*", ATTRS{idVendor}=="0c12", ATTRS{idProduct}=="0e10", MODE="0660", TAG+="uaccess"

      # STRIKEPAD PS4 Grip Add-on
      KERNEL=="hidraw*", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="05c5", MODE="0660", TAG+="uaccess"

      # NVIDIA Shield Portable (2013 - NVIDIA_Controller_v01.01 - In-Home Streaming only)
      KERNEL=="hidraw*", ATTRS{idVendor}=="0955", ATTRS{idProduct}=="7203", MODE="0660", TAG+="uaccess", ENV{ID_INPUT_JOYSTICK}="1", ENV{ID_INPUT_MOUSE}=""

      # NVIDIA Shield Controller (2015 - NVIDIA_Controller_v01.03 over USB hidraw)
      KERNEL=="hidraw*", ATTRS{idVendor}=="0955", ATTRS{idProduct}=="7210", MODE="0660", TAG+="uaccess", ENV{ID_INPUT_JOYSTICK}="1", ENV{ID_INPUT_MOUSE}=""

      # NVIDIA Shield Controller (2017 - NVIDIA_Controller_v01.04 over bluetooth hidraw)
      KERNEL=="hidraw*", KERNELS=="*0955:7214*", MODE="0660", TAG+="uaccess"

      # Astro C40
      KERNEL=="hidraw*", ATTRS{idVendor}=="9886", ATTRS{idProduct}=="0025", MODE="0660", TAG+="uaccess"

      # Thrustmaster eSwap Pro
      KERNEL=="hidraw*", ATTRS{idVendor}=="044f", ATTRS{idProduct}=="d00e", MODE="0660", TAG+="uaccess"

      # EdgeTX and OpenTX radio controllers in gamepad mode over USB hidraw
      KERNEL=="hidraw*", ATTRS{idVendor}=="1209", ATTRS{idProduct}=="4f54", MODE="0660" TAG+="uaccess"

      # Thrustmaster TFRP Rudder
      KERNEL=="hidraw*", ATTRS{idVendor}=="044f", ATTRS{idProduct}=="b679", MODE="0660", TAG+="uaccess"

      # Thrustmaster TWCS Throttle
      KERNEL=="hidraw*", ATTRS{idVendor}=="044f", ATTRS{idProduct}=="b687", MODE="0660", TAG+="uaccess"

      # Thrustmaster T.16000M Joystick
      KERNEL=="hidraw*", ATTRS{idVendor}=="044f", ATTRS{idProduct}=="b10a", MODE="0660", TAG+="uaccess"

      # Performance Designed Products Victrix Pro FS-12 for PS4 & PS5
      KERNEL=="hidraw*", ATTRS{idVendor}=="0e6f", ATTRS{idProduct}=="020c", MODE="0660", TAG+="uaccess"

      # Hori Co., Ltd HORI Wireless Pad ONYX PLUS Wired
      KERNEL=="hidraw*", ATTRS{idVendor}=="0f0d", ATTRS{idProduct}=="012d", MODE="0660", TAG+="uaccess"

      # Hori Co., Ltd HORI Wireless Pad ONYX PLUS Wireless
      KERNEL=="hidraw*", ATTRS{idVendor}=="0f0d", ATTRS{idProduct}=="012b", MODE="0660", TAG+="uaccess"

      # Xbox One Elite 2 Controller
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", KERNELS=="*045E:0B22*", MODE="0660", TAG+="uaccess"

      # Generic SInput Device over USB hidraw
      KERNEL=="hidraw*", ATTRS{idVendor}=="2e8a", ATTRS{idProduct}=="10c6", MODE="0660", TAG+="uaccess"

      # Generic SInput Device over bluetooth hidraw
      KERNEL=="hidraw*", KERNELS=="*2E8A:10C6*", MODE="0660", TAG+="uaccess"

      # ProGCC in SInput Mode over USB hidraw
      KERNEL=="hidraw*", ATTRS{idVendor}=="2e8a", ATTRS{idProduct}=="10df", MODE="0660", TAG+="uaccess"

      # ProGCC in SInput Mode over bluetooth hidraw
      KERNEL=="hidraw*", KERNELS=="*2E8A:10DF*", MODE="0660", TAG+="uaccess"

      # GC Ultimate in SInput Mode over USB hidraw
      KERNEL=="hidraw*", ATTRS{idVendor}=="2e8a", ATTRS{idProduct}=="10dd", MODE="0660", TAG+="uaccess"

      # GC Ultimate in SInput Mode over bluetooth hidraw
      KERNEL=="hidraw*", KERNELS=="*2E8A:10DD*", MODE="0660", TAG+="uaccess"

      # Firebird in SInput Mode over USB hidraw
      KERNEL=="hidraw*", ATTRS{idVendor}=="2e8a", ATTRS{idProduct}=="10e0", MODE="0660", TAG+="uaccess"

      # 8bitdo 2.4 GHz / Wired
      KERNEL=="hidraw*", ATTRS{idVendor}=="2dc8", MODE="0660", TAG+="uaccess"

      # 8bitdo Bluetooth
      KERNEL=="hidraw*", KERNELS=="*2DC8:*", MODE="0660", TAG+="uaccess"

      # Flydigi 2.4 GHz / Wired
      KERNEL=="hidraw*", ATTRS{idVendor}=="04b4", MODE="0660", TAG+="uaccess"

      # Flydigi HIDAPI Enhanced Mode
      KERNEL=="hidraw*", ATTRS{idVendor}=="37d7", MODE="0660", TAG+="uaccess"

      # Nintendo Wii U/Switch Wired GameCube Controller Adapter
      SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTRS{idVendor}=="057e", ATTRS{idProduct}=="0337", MODE="0660", TAG+="uaccess"

      # Nintendo Switch 2 GameCube Controller over USB
      SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTRS{idVendor}=="057e", ATTRS{idProduct}=="2073", MODE="0660", TAG+="uaccess"
    '';
  };

  # power saving
  services.power-profiles-daemon.enable = false;
  services.auto-cpufreq = {
    enable = true;
    settings = {
      battery = {
        governor = "powersave";
        turbo = "never";
      };
      charger = {
        governor = "performance";
        turbo = "auto";
      };
    };
  };

  # enable zram memory compression instead of swapping
  zramSwap = {
    enable = true;
    memoryPercent = 150;
  };

  boot.kernel.sysctl = {
    # according to Arch Wiki, Pop OS uses these settings with zram
    # https://wiki.archlinux.org/title/Zram
    "vm.swappiness" = 180;
    "vm.watermark_boost_factor" = 0;
    "vm.watermark_scale_factor" = 125;
    "vm.page-cluster" = 0;

    # increase various system limits
    "fs.inotify.max_user_watches" = 10485760;
    "fs.aio-max-nr" = 10485760;
    "fs.file-max" = 10485760;
  };

  # enable automatic swap file creation and management on disk
  services.swapspace.enable = true;

  # suspend on lid switch only on battery
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchDocked = "ignore";
    HandleLidSwitchExternalPower = "ignore";
  };

  # system76 scheduler for extra performance
  services.system76-scheduler = {
    enable = true;
    useStockConfig = true;
  };

  # deduplicate files system-wide
  services.duperemove = {
    enable = true;
    hashfile = "/var/lib/duperemove.db";
    paths = ["/home"];
    extraArgs = "-dr";
    systemdInterval = "weekly";
  };

  # enable docker (podman) for dev
  virtualisation.podman = {
    enable = true;
    defaultNetwork.settings = {
      dns_enabled = true;
    };
    autoPrune = {
      enable = true;
      flags = ["--all"];
    };

    dockerCompat = true;
    dockerSocket.enable = true;
  };
  # virtualisation.docker.enable = true;

  # enable nix-ld
  programs.nix-ld.enable = true;

  # enable android tools and associated udev rules
  programs.adb.enable = true;

  services.dbus.implementation = "broker";

  # DO NOT CHANGE
  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "24.11";
}
