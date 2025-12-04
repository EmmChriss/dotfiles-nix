{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.lists) optional;
  inherit (lib.modules) mkIf;
  inherit (lib.options) literalExpression mkOption mkEnableOption;
  inherit
    (lib.types)
    package
    str
    nullOr
    listOf
    ;

  cfg = config.services.duperemove;
in {
  options.services.duperemove = {
    enable = mkEnableOption "Enable periodic deduplication";

    package = mkOption {
      type = package;
      default = pkgs.duperemove;
      defaultText = literalExpression "pkgs.duperemove";
      description = "The duperemove derivation to use";
    };

    hashfile = mkOption {
      type = nullOr str;
      default = null;
      defaultText = literalExpression "null";
      description = "Path to save hashfile (optional)";
    };

    paths = mkOption {
      type = listOf str;
      default = [];
      defaultText = literalExpression "[]";
      description = ''
        Paths to deduplicate. If you're using NixOS, the Nix Store can be deduplicated by nix itself. These paths
        should point to other directories in that case for ex. /home/my-user
      '';
    };

    extraArgs = mkOption {
      type = str;
      default = "";
      defaultText = literalExpression "\"\"";
      description = "Extra arguments to pass to duperemove. Example: -d -r";
    };

    systemdInterval = mkOption {
      type = str;
      default = "daily";
      defaultText = literalExpression "daily";
      description = "See systemd OnCalendar options (for ex. daily, weekly)";
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = builtins.length cfg.paths > 0;
        message = "duperemove: at least one path must be specified";
      }
    ];

    environment.systemPackages = [cfg.package];
    systemd.packages = [cfg.package];

    systemd.services.duperemove = {
      description = "Deduplicate files";
      serviceConfig = {
        Type = "oneshot";
        User = "root";
        ExecStart = builtins.concatStringsSep " " (
          ["${lib.getExe cfg.package} ${cfg.extraArgs}"]
          ++ optional (!isNull cfg.hashfile) "--hashfile=${cfg.hashfile}"
          ++ cfg.paths
        );
      };
    };

    systemd.timers.duperemove = {
      description = "Deduplicate files on a schedule";
      wantedBy = ["timers.target"];
      timerConfig = {
        Persistent = true;
        OnCalendar = cfg.systemdInterval;
      };
    };
  };
}
