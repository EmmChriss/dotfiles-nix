{ config, pkgs, inputs, outputs, lib, ... }:

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

    # Import your generated (nixos-generate-config) hardware configuration
    ./hardware-configuration.nix

    # Handles setting timezone manually and automatically
    ./timezone.nix
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

      # enable hyprland cachix instance to not build hyprland and friends from source
      substituters = ["https://hyprland.cachix.org"];
      trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
    };
    gc = {
      automatic = true;
      dates = "weekly";
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
  networking.networkmanager.enable = true;

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
    bluetooth.enable = true;
    graphics.enable = true;
    nvidia = {
      # modesetting is usually needed
      # TODO: verify if GNOME could be used instead on nouveau
      modesetting.enable = true;
      powerManagement.enable = true;
      powerManagement.finegrained = true;

      open = false;
      nvidiaSettings = false;
      package = config.boot.kernelPackages.nvidiaPackages.stable;

      # Configure PRIME offloading
      prime = {
        offload = {
          enable = true;
          enableOffloadCmd = true;
        };
      };
    };
  };

  # Audio
  security.rtkit.enable = true; # refer to NixOS Wiki:Audio
  services.pipewire = {
    enable = true;
    pulse.enable = true;
    jack.enable = true;

    # bluetooth support
    wireplumber.extraConfig.bluetoothEnhancements = {
      "monitor.bluez.properties" = {
        "bluez5.enable-sbc-xq" = true;
        "bluez5.enable-msbc" = true;
        "bluez5.enable-hw-volume" = true;
        "bluez5.roles" = [ "hsp_hs" "hsp_ag" "hfp_hf" "hfp_ag" ];
      };
    };
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

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
    extraGroups = [ "wheel" "networkmanager" ]; # Enable ‘sudo’ for the user.
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

  # define editor globally
  environment.variables = {
    EDITOR = "hx";
    VISUAL = "hx";
  };

  # Graphics settings
  services.xserver = {
    enable = true;

    # DEFAULT: use nvidia drivers for gui
    videoDrivers = [ "nvidia" ];
    desktopManager.xterm.enable = false;

    # TODO: remove this when hyprland is working
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;

    # X11 keymap
    xkb.layout = "us";
  };

  # GPU Acceleration
  hardware.graphics.extraPackages = [
    pkgs.rocmPackages.clr.icd # AMD OpenCL
    pkgs.amdvlk # AMD Vulkan
  ];

  # Restrict GPU Accel to AMD
  environment.variables.VK_ICD_FILENAMES =
    "/run/opengl-driver/share/vulkan/icd.d/radeon_icd.x86_64.json";

  # BATTERY: secondary boot config that switches off NVIDIA card
  specialisation = {
    battery.configuration = {
      system.nixos.tags = [ "battery" ];
      services.xserver.videoDrivers = lib.mkForce [ ];
      hardware.nvidia = {
        modesetting.enable = lib.mkForce false;
        prime.offload.enable = lib.mkForce false;
        prime.offload.enableOffloadCmd = lib.mkForce false;
      };
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

  # DO NOT CHANGE
  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "24.11";
}

