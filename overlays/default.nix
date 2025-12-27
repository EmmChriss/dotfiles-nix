# This file defines overlays
{...}: {
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
      patches = (old.patches or []) ++ [./tofi-drun-print-desktop.patch];
    });

    # ouch: enable unfree RAR support
    ouch = super.ouch.override (old: {
      enableUnfree = true;
    });
  };
}
