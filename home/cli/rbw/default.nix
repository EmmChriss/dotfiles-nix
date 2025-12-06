{pkgs, ...}: {
  home.sessionVariables = {
    SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/rbw/ssh-agent-socket";
  };

  home.packages = [pkgs.rbw];

  systemd.user.services.rbw-agent = {
    Unit = {
      Description = "Background process for rbw - a terminal client for Bitwarden";
      After = ["graphical-session.target"];
    };
    Service = {
      Type = "exec";
      ExecStart = "${pkgs.writeShellScript "rbw-agent-wrapper" ''
        #!/run/current-system/sw/bin/bash
        export PATH="${pkgs.pinentry-all}/bin:$PATH"
        ${pkgs.rbw}/bin/rbw-agent --no-daemonize
      ''}";
      Restart = "on-failure";
    };
    Install.WantedBy = ["graphical-session.target"];
  };
}
