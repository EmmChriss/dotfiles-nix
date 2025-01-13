# This file defines overlays
{ inputs, ... }: {
  # This one brings our custom packages from the 'pkgs' directory
  additions = self: super: import ../pkgs self.pkgs;

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = self: super: {
    # example = prev.example.overrideAttrs (oldAttrs: rec {
    # ...
    # });

    # tofi: patch in support for printing selected .desktop file in drun mode
    tofi = super.tofi.overrideAttrs (old: {
      patches = (old.patches or []) ++ [ ./tofi-drun-print-desktop.patch ];
    });

    # alacritty: master
    # alacritty = super.alacritty.overrideAttrs (old: rec {
    #   src = super.fetchFromGitHub {
    #     owner = "alacritty";
    #     repo = "alacritty";
    #     rev = "28910e3adc9d48edc4f43008d987eecd869ded31";
    #     hash = "sha256-Ege7Cb4YE9j1AWt7+rMsXE1t7ZTO/jv469cHDV2BywM=";
    #   };

    #   cargoDeps = old.cargoDeps.overrideAttrs (super.lib.const {
    #     name = "alacritty-vendor.tar.gz";
    #     inherit src;
    #     outputHash = "sha256-IP100T9dJa8TRlFruhwu0qUVcVq0IVxBTXWga1cj80U=";
    #   });
    #   # cargoHash = "sha256-IP100T9dJa8TRlFruhwu0qUVcVq0IVxBTXWga1cj80U=";
    # });

    # helix: nixpkgs-unstable
    helix = inputs.nixpkgs-unstable.legacyPackages.${super.system}.helix;
  };

  # When applied, the unstable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.unstable'
  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      system = final.system;
      config.allowUnfree = true;
    };
  };
}
