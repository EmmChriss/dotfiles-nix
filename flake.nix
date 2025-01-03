{
  description = "NixOS Configuration";

  inputs = {
    # Stable nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";

    # NixOS Hardware - master
    nixos-hardware.url = "github:NixOs/nixos-hardware/master";

    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Flake Utils: couple of utility functions
    flake-utils.url = "github:numtide/flake-utils";

    # Nix Colors: manage your colorschemes
    # TODO: use this for something
    # nix-colors.url = "github:misterio77/nix-colors";

    # Nur: Nix User Repository overlays
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Hyprland: upstream hyprland releases; uses cachix
    # NOTE: pinned version to avoid cache misses on newer versions
    hyprland.url = "https://github.com/hyprwm/Hyprland/archive/refs/tags/v0.45.2.tar.gz";

    # Fenix: upstream rust profiles overlays
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Yazi: terminal file manager upstream releases
    # NOTE: pinned version for potential backward-incompatible changes
    yazi.url = "https://github.com/sxyazi/yazi/archive/refs/tags/v0.4.2.tar.gz";
  };

  outputs = { self, systems, flake-utils, nixpkgs, ... }@inputs:
  let pkgs = system: nixpkgs.legacyPackages.${system};
  in
  {

    # Your custom packages
    # Accessible through 'nix build', 'nix shell', etc
    packages = flake-utils.lib.eachDefaultSystem (system: import ./pkgs (pkgs system));

    # Formatter for your nix files, available through 'nix fmt'
    # Other options beside 'alejandra' include 'nixpkgs-fmt'
    # NOTE: formatted code looks quite ugly
    #
    # formatter = eachSystem (pkgs: pkgs.alejandra);
    # formatter = eachSystem (pkgs: pkgs.nixpkgs-fmt);
    # formatter = eachSystem (pkgs: pkgs.nixfmt-rfc-style);

    # Your custom packages and modifications, exported as overlays
    overlays = import ./overlays { inherit inputs; };

    # Reusable nixos modules you might want to export
    # These are usually stuff you would upstream into nixpkgs
    nixosModules = import ./modules/nixos;

    # Reusable home-manager modules you might want to export
    # These are usually stuff you would upstream into home-manager
    homeManagerModules = import ./modules/home;

    # merged system config and home-manager config
    # they build together but are in separate namespaces
    nixosConfigurations = {
      morga = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          # Enable overlays
          {
            nixpkgs.overlays = [
              inputs.nur.overlays.default
              inputs.yazi.overlays.default

              # Fenix workaround for stable nixpkgs caching; ie. instead of:
              # inputs.fenix.overlays.default
              # See: https://github.com/nix-community/fenix
              # See: https://github.com/nix-community/fenix/issues/79
              (_: super: 
                let
                  inherit (inputs) fenix;
                  pkgs = fenix.inputs.nixpkgs.legacyPackages.${super.system};
                in fenix.overlays.default pkgs pkgs
              )
            ];
          }
        
          # Enable Cachix substituters
          {
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
              extraSpecialArgs = { inherit inputs; };
              users.morga = ./home/home.nix;
            };
          }
        ];
        specialArgs = { inherit inputs; };
      };
    };
  };
}
