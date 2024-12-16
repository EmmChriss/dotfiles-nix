{
  description = "NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";

    nixos-hardware.url = "github:NixOs/nixos-hardware/master";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland.url = "github:hyprwm/Hyprland";

    nix-colors.url = "github:misterio77/nix-colors";

    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, systems, nixpkgs, home-manager, nur, nix-colors, ... }@inputs:
  let
    inherit (self) outputs;
    
    # Small tool to iterate over each system
    eachSystem = f: nixpkgs.lib.genAttrs (import systems) (system: f nixpkgs.legacyPackages.${system});
  in
  {

    # Your custom packages
    # Accessible through 'nix build', 'nix shell', etc
    packages = eachSystem (pkgs: import ./pkgs pkgs);

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
          # NixOS system configuration; all rooted in configuration.nix
          ./nixos/configuration.nix

          # Home-manager configuration; all rooted in home.nix
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              backupFileExtension = "homenew";
              useUserPackages = true;
              useGlobalPkgs = true;
              extraSpecialArgs = { inherit inputs; };
              users.morga = ./home/home.nix;
            };
            nixpkgs.overlays = [
              # TODO: look into this
              # nur.overlay
              # (import ./overlays)
            ];
          }
        ];
        specialArgs = { inherit inputs; };
      };
    };
  };
}
