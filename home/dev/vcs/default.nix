{
  pkgs,
  lib,
  ...
}: let
  identities = {
    # optional sshKey
    personal-github = {
      name = "EmmChriss";
      email = "emmchris@protonmail.com";
      sshKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICgiFg4/zoFPYSmEqucqf/JDrniGYCLnvJl4QKgnWuzA";
    };
    oss-github = {
      name = "EmmChriss";
      email = "42001129+EmmChriss@users.noreply.github.com";
      sshKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICgiFg4/zoFPYSmEqucqf/JDrniGYCLnvJl4QKgnWuzA";
    };
    moon42-github = {
      name = "EmmChriss";
      email = "emmchris@protonmail.com";
      sshKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICgiFg4/zoFPYSmEqucqf/JDrniGYCLnvJl4QKgnWuzA";
    };
    prft-github = {
      name = "Molnár Krisztián";
      email = "krisztian.molnar@perficient.com";
    };
    prft-azure = {
      name = "Molnár Krisztián";
      email = "krisztian.molnar@perficient.com";
    };
  };

  extraAllowedSigners = [
    # optional validAfter, validBefore: YYYYMMDD
    # {
    #   principals = ["ci-bot@company.com"];
    #   key = "ssh-ed25519 AAAA... ci";
    #   validBefore = "20271231";
    # }
  ];

  withKeys = lib.filterAttrs (_: v: v ? sshKey) identities;
  keyPath = k: "~/.git/${k}.pub";

  table = lib.concatStringsSep "\n" (lib.mapAttrsToList
    (k: v: "${k}\t${v.name}\t${v.email}\t${lib.optionalString (v ? sshKey) (keyPath k)}")
    identities);

  repo-id = pkgs.writeShellApplication {
    name = "repo-id";
    runtimeInputs = with pkgs; [git jujutsu fzf gawk];
    text = ''
      table=${lib.escapeShellArg table}
      if [ $# -gt 0 ]; then
        line=$(awk -F'\t' -v k="$1" '$1 == k' <<<"$table")
      else
        line=$(fzf --delimiter='\t' --with-nth=1..3 --prompt='identity> ' <<<"$table")
      fi
      [ -n "$line" ] || { echo "unknown profile" >&2; exit 1; }
      IFS=$'\t' read -r _ name email key <<<"$line"

      if jj root >/dev/null 2>&1; then
        jj config set --repo user.name  "$name"
        jj config set --repo user.email "$email"
        if [ -n "$key" ]; then
          jj config set --repo signing.behavior own
          jj config set --repo signing.key "$key"
        else
          jj config set --repo signing.behavior drop
        fi
      fi
      if git rev-parse --git-dir >/dev/null 2>&1; then
        git config --local user.name  "$name"
        git config --local user.email "$email"
        if [ -n "$key" ]; then
          git config --local user.signingKey "$key"
          git config --local commit.gpgSign true
          git config --local tag.gpgSign true
        else
          git config --local --unset user.signingKey || true
          git config --local commit.gpgSign false
          git config --local tag.gpgSign false
        fi
      fi
      echo "identity: $name <$email>''${key:+ (signing: $key)}"
    '';
  };

  signerLine = {
    principals,
    key,
    validAfter ? null,
    validBefore ? null,
  }:
    lib.concatStringsSep " " (lib.filter (s: s != "") [
      (lib.concatStringsSep "," principals)
      ''namespaces="git"''
      (lib.optionalString (validAfter != null) ''valid-after="${validAfter}"'')
      (lib.optionalString (validBefore != null) ''valid-before="${validBefore}"'')
      key
    ]);

  allowedSigners = lib.concatMapStrings (s: signerLine s + "\n") (
    lib.mapAttrsToList (_: v: {
      principals = [v.email];
      key = v.sshKey;
    })
    withKeys
    ++ extraAllowedSigners
  );
in {
  imports = [
    ./jj.nix
    ./git.nix
  ];

  home.file =
    lib.mkMerge
    [
      (lib.mapAttrs'
        (k: v: lib.nameValuePair ".git/${k}.pub" {text = v.sshKey + "\n";})
        withKeys)

      {
        ".ssh/allowed-signers".text = allowedSigners;
      }
    ];

  programs.git = {
    enable = true;
    settings = {
      user.useConfigOnly = true;
      gpg.format = "ssh";
      gpg.ssh.allowedSignersFile = "~/.ssh/allowed-signers";
    };
  };

  programs.jujutsu = {
    enable = true;
    settings.signing = {
      backend = "ssh";
      backends.ssh.allowed-signers = "~/.ssh/allowed-signers";
    };
  };

  home.packages = [repo-id];
}
