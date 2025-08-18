{ pkgs, inputs, outputs, lib, ... }:

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

    # Handles setting timezone manually and automatically
    ./timezone.nix

    # Deduplicate files system-wide
    outputs.nixosModules.duperemove
  ];

  # remove unnecessary preinstalled packages
  environment.defaultPackages = [ ];

  # Nixpkgs settings
  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      # outputs.overlays.additions
      # outputs.overlays.modifications
      # outputs.overlays.unstable-packages

      # You can also add overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];

    # Configure your nixpkgs instance
    config = {
      allowUnfree = true;
    };
  };

  # Nix settings
  nix = {
    settings = {
      auto-optimise-store = true;
      trusted-users = [ "morga" ];
      experimental-features = [ "nix-command" "flakes" ];
    };
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 2d";
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
    bluetooth = {
      enable = true;

      # enables fetchin bluetooth headset battery status
      settings.General.Experimental = true;
    };

    graphics.enable = true;

    nvidia = {
      # modesetting is usually needed
      modesetting.enable = true;
      nvidiaPersistenced = true;
      powerManagement = {
        enable = true;
        finegrained = true;
      };

      open = true;
      nvidiaSettings = false;

      # Configure PRIME offloading
      prime = {
        offload = {
          enable = true;
          enableOffloadCmd = true;
        };
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

    wireplumber.extraConfig."10-bluetooth-enhancements" = {
      "monitor.bluez.properties" = {
        # enable hardware volume
        "bluez5.enable-hw-volume" = true;
      };
      "wireplumber-settings" = {
        # do not switch to headset profile ever
        "bluetooth.autoswitch-to-headset-profile" = false;
      };
    };
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # local network device discovery (printers)
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # Sudo
  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
    extraConfig =
      ''
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
    extraGroups = [ "wheel" "networkmanager" "video" "docker" "adbusers" ];
  };

  # Instead of setting as login shell, run fish immediately when bash starts
  # See: https://nixos.wiki/wiki/Fish
  programs.fish.enable = true;
  programs.bash = {
    interactiveShellInit = ''
      if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
      then
        shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
        exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
      fi
    '';
  };

  # Graphics settings
  services.xserver = {
    enable = true;

    # DEFAULT: use nvidia drivers for gui
    videoDrivers = [ "nvidia" ];
    desktopManager.xterm.enable = false;

    # Use GDM as DM
    displayManager.gdm = {
      enable = true;
      wayland = true;
    };

    # X11 keymap
    xkb.layout = "us";
  };

  # NOTE: hyprland is installed here, but configured in home-manager
  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };

  # GPU Acceleration
  hardware.graphics.extraPackages = [
    # pkgs.rocmPackages.clr.icd # AMD OpenCL
    pkgs.amdvlk # AMD Vulkan
  ];

  # verify setup with `vulkaninfo`, `glxinfo`, `clinfo`, `vainfo`, `vdpauinfo`
  # prefer Intel's VA-API over Nvidia's VDPAU, still use the AMD VDPAU driver
  environment.variables = {
    # LIBVA_DRIVER_NAME = "radeonsi";
    # VDPAU_DRIVER = "radeonsi";
    # LIBVA_DRIVER_NAME = "nvidia";
    # VDPAU_DRIVER = "nvidia";
  };

  # BATTERY: secondary boot config that switches off NVIDIA card
  specialisation.battery.configuration = { ... }: {
    # nixos-hardware: disable nvidia module
    imports = [ inputs.nixos-hardware.nixosModules.common-gpu-nvidia-disable ];
  
    system.nixos.tags = [ "battery" ];
    services.xserver.videoDrivers = lib.mkForce [ ];
    hardware.nvidia = {
      modesetting.enable = lib.mkForce false;
      nvidiaPersistenced = lib.mkForce false;
      prime.offload.enable = lib.mkForce false;
      prime.offload.enableOffloadCmd = lib.mkForce false;
    };

    # Restrict GPU Accel to AMD
    environment.variables = {
      # VK_ICD_FILENAMES = lib.mkForce "/run/opengl-driver/share/vulkan/icd.d/radeon_icd.x86_64.json";
      # LIBVA_DRIVER_NAME = lib.mkForce "radeonsi";
      # VDPAU_DRIVER = lib.mkForce "radeonsi";
    };
  };

  # enable Thunar file manager
  # needed to open archive files without extracting
  programs.thunar = with pkgs.xfce; {
    enable = true;
    plugins = [
      thunar-archive-plugin
      thunar-volman
    ];
  };

  # stuff for thunar?
  programs.xfconf.enable = true;

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
    memoryPercent = 100;
  };

  # according to Arch Wiki, Pop OS uses these settings with zram
  # https://wiki.archlinux.org/title/Zram
  boot.kernel.sysctl = {
    "vm.swappiness" = 180;
    "vm.watermark_boost_factor" = 0;
    "vm.watermark_scale_factor" = 125;
    "vm.page-cluster" = 0;
  };

  # enable automatic swap file creation and management on disk
  services.swapspace.enable = true;

  # suspend on lid switch only on battery
  services.logind = {
    lidSwitch = "suspend";
    lidSwitchDocked = "ignore";
    lidSwitchExternalPower = "ignore";
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
    paths = [ "/home" ];
    extraArgs = "-dr";
    systemdInterval = "weekly";
  };

  # enable gpg agent system-wide with ssh-agent emulation
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    enableBrowserSocket = true;
    pinentryPackage = pkgs.pinentry-all;
  };

  # enable docker for dev
  virtualisation.docker = {
    enable = true;
    enableOnBoot = false;
    autoPrune.enable = true;
  };

  # enable nix-ld
  programs.nix-ld.enable = true;

  # enable android tools and associated udev rules
  programs.adb.enable = true;

  # DO NOT CHANGE
  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "24.11";
}

