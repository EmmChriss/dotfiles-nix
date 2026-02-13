{lib, ...}: {
  imports = [
    ./jj.nix
    ./git.nix
  ];

  options.home.vcs = with lib; {
    signature = mkOption {
      type = types.str;
    };
    name = mkOption {
      type = types.str;
    };
    email = mkOption {
      type = types.str;
    };
  };

  config.home.vcs = {
    signature = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICgiFg4/zoFPYSmEqucqf/JDrniGYCLnvJl4QKgnWuzA";
    name = "EmmChriss";
    email = "emmchris@protonmail.com";
  };
}
