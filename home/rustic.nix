{ pkgs, lib, ... }:

let
  tomlFormat = pkgs.formats.toml { };
  backupScript = pkgs.writeShellApplication {
    name = "backup-rustic";
    runtimeInputs = with pkgs; [ expect age rclone rustic libnotify zenity ];
    text = ''
      # make sure we even have internet connectivity
      ping -c3 linux.org >/dev/null 2>&1 || exit 1
      # ask user about starting backup
      zenity --question --text "Start backup now?" || exit 1

      # set password command explicitly
      export RCLONE_PASSWORD_COMMAND="pass rclone/config";
      # set bandwidth limit
      export RCLONE_BWLIMIT=1M

      # make sure we are concerned with current user
      cd ~

      # start with a low-bandwidth secrets backup
      {
        notify-send "Starting secrets backup.."

        # fetch passphrase to encrypt with
        passphrase="$(pass secrets)"

        # create tempfiles for intermediaries
        archive="$(mktemp)"
        encrypted="$(mktemp)"

        # cleanup: remove tempfiles
        trap 'rm "$encrypted"; rm "$archive"' EXIT

        # archive secrets into tempfile
        pushd ~
        tar czf - .ssh .gnupg .megaCmd .password-store .pki >"$archive"
        popd

        # encrypt archive with passphrase
        # NOTE: age is retarded about taking passphrases from environment
        # expect script taken from https://github.com/FiloSottile/age/pull/520
        expect <<-EOF
        log_user 0
        spawn age -e -p -o "$encrypted" "$archive"
        send -- "$passphrase\n"
        # confirmation
        send -- "$passphrase\n"
        expect -- "\n"
        log_user 1
        expect eof
EOF

        # upload secret archive to cloud storage
        rclone rcat --size-only mega:Secrets/secrets.tar.gz.age <"$encrypted"
      } || notify-send "Secrets backup failed"

      # do full backup
      {
        notify-send "Starting backup.."
        rustic backup
      } || notify-send "Backup failed"

      {
        notify-send "Cleaning backup.."
        rustic forget --prune --early-delete-index
      } || notify-send "Cleaning backup failed"

      {
        notify-send "Repairing backup.."
        rustic repair index
      } || notify-send "Repairing backup failed"
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
    repository = {
      repository = "rclone:mega:Backups";
      password-command = "pass rustic";
    };

    forget = {
      prune = true;
      keep-last = 2;
      keep-daily = 2;
      keep-weekly = 2;
      keep-monthly = 2;
    };

    backup = {
      exclude-if-present = [".nobackup" "CACHEDIR.TAG"];
      custom-ignorefiles = [".rusticignore" ".backupignore"];
      iglobs = [
        "!downloads" "!node_modules" "!target" "!venv"
        "!.cache" "!.local/state" "!.cargo" "!.npm" "!.pnpm"
        "!uv" "!Trash" "!teams-for-linux" "!.rustup" "!.bun"
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
      RestartSec = "1h";
    };
  };

  systemd.user.timers.rustic-backup = {
    Unit.Description = "automatic remote backup snapshots";
    Timer = {
      Persistent = true;
      OnCalendar = "daily";
      RandomizedDelaySec = "10m";
    };
    Install = { WantedBy = [ "timers.target" ]; };
  };
}
