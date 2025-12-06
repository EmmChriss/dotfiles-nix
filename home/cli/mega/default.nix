{pkgs, ...}: {
  home.packages = [pkgs.megacmd];
  systemd.user.services.megacmd = {
    Unit = {
      Description = "Sync user directories to MEGA";
      After = ["network-online.target"];
    };
    Service = {
      ExecStart = "${pkgs.megacmd}/bin/mega-cmd-server";
      Restart = "always";
    };
    Install.WantedBy = ["default.target"];
  };
}
