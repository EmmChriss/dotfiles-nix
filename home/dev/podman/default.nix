{pkgs, ...}: {
  home.packages = with pkgs; [
    podman-compose
    (writeShellApplication {
      name = "docker-compose";
      runtimeInputs = [pkgs.podman-compose];
      text = ''${lib.getExe pkgs.podman-compose} "$@"'';
    })
    podman-tui
  ];
}
