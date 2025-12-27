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
    # dbeaver requires pg_dump and pg_restore
    postgresql
    pgcli

    # languages
    python3
    clang
    typst

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
