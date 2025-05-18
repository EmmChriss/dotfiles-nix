{ pkgs, lib, ... }:

let 
  tomlFormat = pkgs.formats.toml { };
  backupScript = pkgs.writeShellApplication {
    name = "backup-rustic";
    runtimeInputs = with pkgs; [ age rclone rustic libnotify ];
    text = ''
      ping -c3 linux.org >/dev/null 2>&1 || exit 1
    
      {
        notify-send "Starting backup.."

        rustic backup
      } || notify-send "Backup failed"

      {
        cd /home/morga
        export RCLONE_PASSWORD_COMMAND="pass rclone/config"
        notify-send "Starting secrets backup.."

        # compress, encrypt and upload secrets
        tar czf - .age .ssh .gnupg .megaCmd .password-store .pki \
        | age -e -i .age/key-secrets.txt \
        | rclone rcat --size-only mega:Secrets/secrets.tar.gz.age

        # also upload encrypted key file
        rclone rcat --size-only mega:Secrets/key-secrets.txt.age < .age/key-secrets.txt.age
      } || notify-send "Secrets backup failed"
      
      {
        notify-send "Cleaning backup.."

        rustic forget --prune --instant-delete --fast-repack --no-resize
      } || notify-send "Cleaning backup failed"

      {
        notify-send "Repairing backup.."

        rustic repair index
      } || notify-send "Repairing backup failed"
      
      notify-send "Backup successfull"
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
      iglobs = [
        "!downloads" "!node_modules" "!target" "!venv"
        "!.cache" "!.local/state" "!.cargo" "!.npm" "!.pnpm"
        "!uv" "!dump*.tar" "!Trash" "!teams-for-linux"
      ];
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
      Persistent = true;
      OnCalendar = "daily";
      RandomizedDelaySec = "1h";
    };
    Install = { WantedBy = [ "timers.target" ]; };
  };
}
