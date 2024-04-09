{
  description = "TheButlah's personal dev environment";
  inputs = {
    # Worlds largest repository of linux software
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    # Provides eachDefaultSystem and other utility functions
    utils.url = "github:numtide/flake-utils";
    # Replacement for rustup
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, utils, fenix, home-manager }: {
    nixosConfigurations = {
      ryan-mac-utm = nixpkgs.lib.nixosSystem rec {
        system = "aarch64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./machines/ryan-mac-utm/configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.ryan = import ./home.nix;
            home-manager.extraSpecialArgs = { pkgs = nixpkgs.legacyPackages.${system}; };
          }
        ];
      };
      nixos = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./machines/nixos/configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.ryan = import ./home.nix;
            home-manager.extraSpecialArgs = { pkgs = nixpkgs.legacyPackages.${system}; isWork = false; };
          }
        ];
      };
    };
    homeConfigurations."ryan@ryan-laptop" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages."aarch64-darwin";
      modules = [ ./home.nix ];
      extraSpecialArgs = { isWork = false; };
    };
    homeConfigurations."ryan@ryan-worldcoin-asahi" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages."aarch64-linux";
      modules = [ ./home.nix ];
      extraSpecialArgs = { isWork = true; };
    };
    homeConfigurations."ryan@ryan-worldcoin" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages."aarch64-darwin";
      modules = [ ./home.nix ];
      extraSpecialArgs = { isWork = true; };
    };
  } //
  # This helper function is used to more easily abstract
  # over the host platform.
  # See https://github.com/numtide/flake-utils#eachdefaultsystem--system---attrs
  utils.lib.eachDefaultSystem (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
      allPackages = import ./packages/all.nix { inherit pkgs; };
    in
    # See https://nixos.wiki/wiki/Flakes#Output_schema
    {
      apps."home-manager" = {
        type = "app";
        program = "${pkgs.home-manager}/bin/home-manager";
      };
      # This formats the nix files, not the rest of the repo.
      formatter = pkgs.nixpkgs-fmt;
    }
  );
}
