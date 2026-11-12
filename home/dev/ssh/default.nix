{lib, ...}: let
  keys = {
    mine = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB5eCz75BpnbQFr8NCYap75ZYEP+OGaOxGVA87UavKjH";
    moon42_ionos = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICN9qsRqbVA9CbttndpC7qomdi+2fjsQZ+9M8HXgAVhI";
    moon42_ionos_cert = "ssh-ed25519-cert-v01@openssh.com AAAAIHNzaC1lZDI1NTE5LWNlcnQtdjAxQG9wZW5zc2guY29tAAAAIEI38OYJn2cJqfqgnD78MugXBU6TOi7rFRfTwglixE4gAAAAICN9qsRqbVA9CbttndpC7qomdi+2fjsQZ+9M8HXgAVhIAAAAAAAAAAAAAAABAAAADm1vcmdhIHVzZXIga2V5AAAAGgAAABZzeXNhZG1pbkBkb2t1LWNvYWNoLmRlAAAAAGmurIIAAAAAa4/hLgAAAAAAAACCAAAAFXBlcm1pdC1YMTEtZm9yd2FyZGluZwAAAAAAAAAXcGVybWl0LWFnZW50LWZvcndhcmRpbmcAAAAAAAAAFnBlcm1pdC1wb3J0LWZvcndhcmRpbmcAAAAAAAAACnBlcm1pdC1wdHkAAAAAAAAADnBlcm1pdC11c2VyLXJjAAAAAAAAAAAAAAAzAAAAC3NzaC1lZDI1NTE5AAAAILM66fzwYYUMm+iSNd1KCOlMzGVTb+xv2ZTDX2uCWzL9AAAAUwAAAAtzc2gtZWQyNTUxOQAAAEBicU/N+eGH+sQUD6u1TF1TI5fyAaVg6IBmgbS/g5EXBdat131SfM5155fuRM/r79mxPMY2ZKVAxVgFvQ7ipz8K";
    prft_github = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOsvsf1gApydV/C8+o46UWu1dQmJZykv/icyTNFjYetc";
    prft_azure = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC8Sa0vVC0RaJ1Hcvo23KlZ/gfNprsnZDv7iHxTvW0oQ6SNsBrWsJYIxcUYHKwmFDTlvPhtyLEBeMCUrfL3A/fVP6CY1CmQVUlZOFHBN4PiQZzP9duT0pLpvVFj7iOkSucJTY3awmDKVUIoKbRAGFaOfYu5OHJhy4XGD0/MSMjF7Rm0vp6FFGhXYg1yK3APDuomNV4GnimlhTovbz6geurXt5GoT3PGSBY3EK5o2Bq29vb49/fXSQ0/PJetF+X8iRjyuJUvkGwNmbyXjFTOjafmdO2Ap2iTpUQxjeJv0HcD7+nsNvSHFNLOhPhkPhCdo9hiG2oCvSiuahUB0E71o2H56ihufHTo8s2U3D3NKenzJhnMhPLHSg4gz6G0+rOrfTClJxyLGdjCdJftGB/76ocv6zwurchMT5MLh8/dscNxTZ5oCEEwkUnMV6c3u8DCodNIke2wUUXaxoMuEsbFDbVIpnd2V5zyNqKsO69M5Tg94xH5FYA/T6tFFedxoxNLvZM=";
  };

  key = name: "~/.ssh/${name}.pub";
in {
  home.file =
    lib.mapAttrs'
    (k: v: lib.nameValuePair ".ssh/${k}.pub" {text = v + "\n";})
    keys;

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings = {
      "emmchris" = {
        "PubkeyAuthentication" = "yes";
        "IdentitiesOnly" = "no";
        "Hostname" = "116.203.189.106";
        "User" = "morga";
      };
      "doku gateway1 gateway2 pg1 pg2 client1 client2 client3 service1" = {
        "PubkeyAuthentication" = "yes";
        "IdentityFile" = key "moon42_ionos";
        "CertificateFile" = key "moon42_ionos_cert";
        "User" = "sysadmin";
      };
      "doku" = {
        "PubkeyAuthentication" = "yes";
        "Hostname" = "ionos.doku-coach.de";
      };
      "personal-github" = {
        "PubkeyAuthentication" = "yes";
        "IdentityFile" = key "mine";
        "Hostname" = "github.com";
        "User" = "git";
      };
      "prft-github" = {
        "PubkeyAuthentication" = "yes";
        "IdentityFile" = key "prft_github";
        "Hostname" = "github.com";
        "User" = "git";
      };
      "prft-azure" = {
        "PubkeyAuthentication" = "yes";
        "IdentityFile" = key "prft_azure";
        "Hostname" = "vs-ssh.visualstudio.com";
        "User" = "smedix";
      };
      "*" = {
        # disable all auth
        "PubkeyAuthentication" = "no";
        "IdentitiesOnly" = "yes";
        "ForwardAgent" = "no";

        # general options
        "Compression" = "yes";
        "ConnectionAttempts" = "3";
        "ConnectTimeout" = "10";
        "StrictHostKeyChecking" = "no";
      };
    };
  };
}
