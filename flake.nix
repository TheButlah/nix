{
  description = "TheButlah's personal dev environment";
  inputs = {
    # Worlds largest repository of linux software
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # Provides eachDefaultSystem and other utility functions
    utils.url = "github:numtide/flake-utils";
    # Replacement for rustup
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
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
    };
  } //
  # This helper function is used to more easily abstract
  # over the host platform.
  # See https://github.com/numtide/flake-utils#eachdefaultsystem--system---attrs
  utils.lib.eachDefaultSystem (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
      # Gets the same rust toolchain that rustup would have used.
      # Note: You don't *have* to do the build with `nix build`,
      # you can still `cargo zigbuild`.
      rustToolchain = fenix.packages.${system}.fromToolchainFile {
        file = ./rust-toolchain.toml;
        sha256 = "R0F0Risbr74xg9mEYydyebx/z0Wu6HI0/KWwrV30vZo=";
      };
      allPackages = import ./packages/all.nix { inherit pkgs; };
    in
    # See https://nixos.wiki/wiki/Flakes#Output_schema
    {
      # I'm using this as a replacement for brew
      packages.default = pkgs.buildEnv {
        name = "my-packages";
        paths = allPackages;
      };
      devShells.default = pkgs.mkShell
        {
          name = "my-dev-shell";
          buildInputs = allPackages;
        };
      # This formats the nix files, not the rest of the repo.
      formatter = pkgs.nixpkgs-fmt;
    }
  );
}
