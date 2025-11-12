{
  pkgs,
  lib,
  ...
}: let
  tomlFormat = pkgs.formats.toml {};
  backupScript = pkgs.writeShellApplication {
    name = "backup-rustic";
    runtimeInputs = with pkgs; [expect age rclone rustic libnotify zenity];
    text = ''
            # make sure we even have internet connectivity
            ping -c3 linux.org >/dev/null 2>&1 || exit 1
            # ask user about starting backup
            zenity --question --text "Start backup now?" || exit 1

            # make sure we are concerned with current user
            cd ~

            # start with a low-bandwidth secrets backup
            {
              notify-send "Starting secrets backup.."

              # fetch passphrase to encrypt with
              passphrase="$(rbw get secrets)"

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
              rclone rcat backups-home:secrets.tar.gz.age <"$encrypted"
            } || notify-send "Secrets backup failed"

            # do full backup
            {
              notify-send "Starting backup.."
              rustic backup
            } || notify-send "Backup failed"

            {
              notify-send "Cleaning backup.."
              rustic forget --prune --max-repack 0 --check-index
            } || notify-send "Cleaning backup failed"

            {
              notify-send "Repairing backup.."
              rustic repair index
              rustic repair snapshots
            } || notify-send "Repairing backup failed"
    '';
  };
in {
  home.packages = with pkgs; [backupScript rclone rustic];

  xdg.configFile."rustic/rustic.toml".source = tomlFormat.generate "rustic.toml" {
    repository = {
      repository = "rclone:backups-home:";
      password-command = "rbw get rustic";
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
        "!.bun"
        "!.cache"
        "!.cargo"
        "!.local/share/fnm"
        "!.local/share/uv"
        "!.local/state"
        "!.npm"
        "!.pnpm"
        "!.rustup"
        "!Trash"
        "!node_modules"
        "!target"
        "!teams-for-linux"
        "!venv"
      ];
      one-file-system = true;
      snapshots = [
        {sources = ["/home/"];}
        {sources = ["/mnt/data/Books"];}
        {sources = ["/mnt/data/Notes"];}
        {sources = ["/mnt/data/Media"];}
        {sources = ["/mnt/data/Documents"];}
        {sources = ["/mnt/data/Downloads"];}
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
    Install = {WantedBy = ["timers.target"];};
  };
}
