{pkgs, ...}: {
  imports = [
    ./node
    ./rust
    ./podman
    ./vcs
  ];

  home.packages = with pkgs; [
    # databases
    dbeaver-bin
    pgcli

    # languages
    python3
    clang

    # package managers
    uv

    # cloud
    heroku
    flyctl

    # web
    xh
    (writeShellApplication {
      name = "http";
      runtimeInputs = [xh];
      text = ''${lib.getExe pkgs.xh} "$@"'';
    })

    # git
    gitui
  ];
}
