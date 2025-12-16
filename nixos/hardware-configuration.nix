{modulesPath, ...}: {
  imports = [(modulesPath + "/installer/scan/not-detected.nix")];

  boot = {
    initrd = {
      availableKernelModules = [
        "nvme"
        "xhci_pci"
        "ahci"
        "usb_storage"
        "usbhid"
        "sd_mod"
      ];
      kernelModules = [];
    };
    kernelModules = ["kvm-amd"];
    extraModulePackages = [];
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/da14a8f0-e6af-4f00-bd78-2e4739945983";
    fsType = "xfs";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/8addd33a-1ea0-44e3-9e04-5f11a6e0df6a";
    fsType = "ext4";
  };

  fileSystems."/boot/efi" = {
    device = "/dev/disk/by-uuid/84D6-F1BC";
    fsType = "vfat";
    options = [
      "fmask=0022"
      "dmask=0022"
    ];
  };

  fileSystems."/mnt/win" = {
    device = "/dev/disk/by-uuid/CCF83614F835FD70";
    fsType = "ntfs";
  };

  fileSystems."/mnt/data" = {
    device = "/dev/disk/by-uuid/5AFA4617FA45EFB5";
    fsType = "ntfs";
  };

  swapDevices = [];

  nixpkgs.hostPlatform = "x86_64-linux";
}
