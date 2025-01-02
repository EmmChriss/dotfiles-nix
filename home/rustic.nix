{ pkgs, lib, ... }:

let 
  tomlFormat = pkgs.formats.toml { };
  backupScript = pkgs.writeShellApplication {
    name = "rustic-backup";
    runtimeInputs = with pkgs; [ rclone rustic libnotify ];
    text = ''
      notify-send "Starting backup.."
      rustic backup
      notify-send "Cleaning backup.."
      rustic verify && rustic forget --prune
      notify-send "Backup finished"
    '';
  };
in
{
  home.packages = with pkgs; [ backupScript rclone rustic ];

  # for general rclone usage, set as user global
  home.sessionVariables = {
      RCLONE_PASSWORD_COMMAND = "pass rclone/config";
  };

  xdg.configFile."rustic/rustic.toml".source = tomlFormat.generate "rustic.toml" {
    # needed for systemd
    global.env = {
      RCLONE_BWLIMIT = "1M"; # to limit bandwidth; unset to turn off
      RCLONE_PASSWORD_COMMAND = "pass rclone/config";
    };
  
    repository = {
      repository = "rclone:mega:Backups";
      password-command = "pass rustic";
    };

    forget = {
      prune = true;
      keep-within-daily = "7 days";
      keep-monthly = 5;
      keep-yearly = 2;
    };

    backup = {
      exclude-if-present = [".nobackup" "CACHEDIR.TAG"];
      custom-ignorefiles = [".rusticignore" ".backupignore"];
      iglobs = ["!downloads" "!node_modules" "!target" "!venv" "!.cache" "!.local/state"];
      one-file-system = true;
      snapshots = [
        { sources = ["/home/"]; }
        { sources = ["/mnt/data/Books"]; }
        { sources = ["/mnt/data/Notes"]; }
        { sources = ["/mnt/data/Documents"]; }
      ];
    };
  };

  systemd.user.services.rustic-backup = {
    Unit.Description = "create remote backup snapshot";
    Service = {
      Type = "oneshot";
      ExecStart = "${lib.getExe backupScript}";
      Restart = "on-failure";
      RestartSec = "10m";
    };
  };

  systemd.user.timers.rustic-backup = {
    Unit.Description = "automatic remote backup snapshots";
    Timer = {
      OnBootSec = "10m";
      OnUnitActiveSec = "24h";
    };
    Install = { WantedBy = [ "timers.target" ]; };
  };
}
