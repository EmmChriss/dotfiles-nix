{ pkgs, config, lib, inputs, outputs, nix-colors, ... }:

let storePath = "${config.home.homeDirectory}/.password-store";
in
{
  # enable pass with otp support
  programs.password-store = {
    enable = true;
    package = pkgs.pass.withExtensions (exts:
      with exts; [
        pass-otp
        pass-audit
        pass-import
      ]
    );
    settings.PASSWORD_STORE_DIR = storePath;
  };

  # enable pass secret service
  services.pass-secret-service.enable = true;
}
