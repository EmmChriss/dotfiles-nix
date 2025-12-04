{
  description = "NixOS Configuration";

  inputs = {
    # Stable nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";

    # Unstable nixpkgs
    nixpkgs-unstable.url = "github:nixos/nixpkgs/master";

    # NixOS Hardware - master
    nixos-hardware.url = "github:NixOs/nixos-hardware/master";

    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Yazi: terminal file manager upstream releases
    # NOTE: pinned version for potential backward-incompatible changes
    yazi.url = "https://github.com/sxyazi/yazi/archive/refs/tags/v0.4.2.tar.gz";
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    ...
  } @ inputs: let
    inherit (self) outputs;
    forAllSystems = fn: nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed fn;
    forAllPackages = fn: forAllSystems (system: fn nixpkgs.legacyPackages.${system});
  in {
    # Devshell
    devShell = forAllPackages (
      pkgs:
        with pkgs;
          mkShellNoCC {
            packages = [
              nh
              just
              alejandra
            ];
          }
    );

    # Your custom packages ('nix build', 'nix shell' etc)
    packages = forAllPackages (pkgs: import ./pkgs pkgs);

    # Formatter for your nix files, available through 'nix fmt'
    formatter = forAllPackages (pkgs: pkgs.alejandra);

    # Your custom packages and modifications, exported as overlays
    overlays = import ./overlays {inherit inputs;};

    # Reusable nixos modules you might want to export
    nixosModules = import ./modules/nixos;

    # Reusable home-manager modules you might want to export
    homeManagerModules = import ./modules/home;

    # NixOS configuration
    nixosConfigurations = {
      morga = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs outputs;};
        modules = [
          # Configure nixpkgs
          {
            nixpkgs.config.allowUnfree = true;

            # Enable overlays
            nixpkgs.overlays = [
              # use the unstable version of some packages
              (
                let
                  pkgs = nixpkgs-unstable.legacyPackages.x86_64-linux;
                in
                  self: super: {
                    inherit
                      (pkgs)
                      helix
                      satty
                      jujutsu
                      rbw
                      ;
                  }
              )

              # import some of our own overlays
              self.overlays.modifications
              self.overlays.additions

              # import package flake overlays
              inputs.yazi.overlays.default
            ];

            # Enable Cachix substituters
            nix.settings = {
              substituters = [
                "https://hyprland.cachix.org"
                "https://nix-community.cachix.org"
                "https://yazi.cachix.org"
              ];
              trusted-public-keys = [
                "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
                "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
                "yazi.cachix.org-1:Dcdz63NZKfvUCbDGngQDAZq6kOroIrFoyO064uvLh8k="
              ];
            };
          }

          # NixOS system configuration; all rooted in configuration.nix
          ./nixos/configuration.nix

          # Home-manager configuration; all rooted in home.nix
          inputs.home-manager.nixosModules.home-manager
          {
            home-manager = {
              backupFileExtension = "homenew";
              useUserPackages = true;
              useGlobalPkgs = true;
              users.morga = ./home/home.nix;
            };
          }
        ];
      };
    };
  };
}
