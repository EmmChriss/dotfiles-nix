{
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
  };

  # enable Thunar file manager with plugins
  programs.thunar = with pkgs.xfce; {
    enable = true;
    plugins = [
      thunar-archive-plugin
      thunar-volman
      thunar-vcs-plugin
      thunar-media-tags-plugin
    ];
  };

  # also file manager stuff
  services.gvfs.enable = true;
  services.tumbler.enable = true;

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

  # enable nix-ld
  programs.nix-ld.enable = true;

  # enable android tools and associated udev rules
  programs.adb.enable = true;

  services.dbus.implementation = "broker";

  # DO NOT CHANGE
  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "24.11";
}
