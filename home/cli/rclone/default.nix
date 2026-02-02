{pkgs, ...}: let
  RCLONE_PASSWORD_COMMAND = ''${pkgs.rbw}/bin/rbw get --folder rclone config'';
in {
  home.packages = with pkgs; [
    rclone
    rclone-browser
  ];

  home.sessionVariables = {
    inherit RCLONE_PASSWORD_COMMAND;
  };

  systemd.user.sessionVariables = {
    inherit RCLONE_PASSWORD_COMMAND;
  };

  home.shellAliases.mnt-nas = "systemctl --user start mnt-storage";

  systemd.user.services.mnt-storage = {
    Unit = {
      Description = "Programmatic mount configuration with rclone";
      After = ["network-online.target"];
    };
    Service = {
      Type = "notify";
      ExecStart = "${pkgs.rclone}/bin/rclone --vfs-cache-mode full --vfs-cache-min-free-space 5G --vfs-refresh --no-modtime --ignore-checksum --rc --rc-addr 'localhost:5572' --rc-serve --rc-web-gui --rc-web-gui-no-open-browser mount storage: /mnt/storage";
      ExecStop = "/run/wrappers/bin/fusermount -u /mnt/storage";
    };
  };
}
