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
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    home-manager,
    ...
  } @ inputs: let
    inherit (self) outputs;
    forAllSystems = fn: nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed fn;
    forAllPackages = fn: forAllSystems (system: fn nixpkgs.legacyPackages.${system});
    nixpkgsConfig = {
      # Always allow unfree
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
      ];
    };
  in {
    # Devshell
    devShell = forAllPackages (
      pkgs:
        with pkgs;
          mkShellNoCC {
            packages = [
              nh
              just
              pkgs.home-manager
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
    homeModules = import ./modules/home;

    # Home-manager configurations
    homeConfigurations.morga = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      modules = [
        # Configure nixpkgs
        nixpkgsConfig

        {
          home = {
            username = "morga";
            homeDirectory = "/home/morga";
          };
        }

        # HM configuration; all rooted in home.nix
        ./home/home.nix
      ];
    };

    # NixOS configuration
    nixosConfigurations.morga = nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs outputs;};
      modules = [
        # Configure nixpkgs
        nixpkgsConfig

        # NixOS system configuration; all rooted in configuration.nix
        ./nixos/configuration.nix
      ];
    };
  };
}
