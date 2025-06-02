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
