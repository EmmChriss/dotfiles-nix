{pkgs, ...}: let
  RCLONE_PASSWORD_COMMAND = ''${pkgs.rbw}/bin/rbw get --folder rclone config'';
in {
  home.packages = with pkgs; [
    rclone
  ];

  home.sessionVariables = {
    inherit RCLONE_PASSWORD_COMMAND;
  };

  systemd.user.sessionVariables = {
    inherit RCLONE_PASSWORD_COMMAND;
  };

  home.shellAliases.mnt-nas = "systemctl --user start mnt-storage mnt-encrypted";

  systemd.user.services.mnt-storage = {
    Unit = {
      Description = "Programmatic mount configuration with rsync";
      After = ["network-online.target"];
    };
    Service = {
      Type = "notify";
      ExecStart = "${pkgs.rclone}/bin/rclone --vfs-cache-mode full --vfs-cache-max-size 5G --no-modtime --ignore-checksum mount storage: /mnt/storage";
      ExecStop = "/run/wrappers/bin/fusermount -u /mnt/storage";
    };
  };

  systemd.user.services.mnt-encrypted = {
    Unit = {
      Description = "Programmatic mount configuration with rsync";
      After = ["network-online.target"];
    };
    Service = {
      Type = "notify";
      ExecStart = "${pkgs.rclone}/bin/rclone --vfs-cache-mode full --vfs-cache-max-size 5G --no-modtime --ignore-checksum mount encrypted: /mnt/encrypted";
      ExecStop = "/run/wrappers/bin/fusermount -u /mnt/encrypted";
    };
  };
}
