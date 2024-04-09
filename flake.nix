{
  description = "TheButlah's personal dev environment";
  inputs = {
    # Worlds largest repository of linux software
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    # Provides eachDefaultSystem and other utility functions
    flake-utils.url = "github:numtide/flake-utils";
    # Replacement for rustup
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixgl = {
      url = "github:nix-community/nixGL";
      # inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, nixgl, flake-utils, fenix, home-manager }:
    let
      mkPkgs = (system: import nixpkgs {
        inherit system;
        overlays = [ nixgl.overlay ];
      });
    in
    {
      nixosConfigurations = {
        ryan-mac-utm = (mkPkgs "aarch64-linux").lib.nixosSystem rec {
          system = "aarch64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            ./machines/ryan-mac-utm/configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.ryan = import ./home.nix;
              home-manager.extraSpecialArgs = { pkgs = (mkPkgs system); };
            }
          ];
        };
        nixos = (mkPkgs "x86_64-linux").lib.nixosSystem rec {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            ./machines/nixos/configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.ryan = import ./home.nix;
              home-manager.extraSpecialArgs = { pkgs = (mkPkgs system); isWork = false; };
            }
          ];
        };
      };
      homeConfigurations."ryan@ryan-laptop" = home-manager.lib.homeManagerConfiguration {
        pkgs = (mkPkgs "aarch64-darwin");
        modules = [ ./home.nix ];
        extraSpecialArgs = { isWork = false; };
      };
      homeConfigurations."ryan@ryan-worldcoin-asahi" = home-manager.lib.homeManagerConfiguration {
        pkgs = (mkPkgs "aarch64-linux");
        modules = [ ./home.nix ];
        extraSpecialArgs = { isWork = true; };
      };
      homeConfigurations."ryan@ryan-worldcoin" = home-manager.lib.homeManagerConfiguration {
        pkgs = (mkPkgs "aarch64-darwin");
        modules = [ ./home.nix ];
        extraSpecialArgs = { isWork = true; };
      };
    } //
    # This helper function is used to more easily abstract
    # over the host platform.
    # See https://github.com/numtide/flake-utils#eachdefaultsystem--system---attrs
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = (mkPkgs system);
        allPackages = import ./packages/all.nix { inherit pkgs; };
        mkApp = (name: { type = "app"; program = "${pkgs.${name}}/bin/${name}"; });
        nixGLWrap = pkg: pkgs.runCommand "${pkg.name}-nixgl-wrapper" { } ''
          mkdir $out
          ln -s ${pkg}/* $out
          rm $out/bin
          mkdir $out/bin
          for bin in ${pkg}/bin/*; do
           wrapped_bin=$out/bin/$(basename $bin)
           echo "exec ${pkgs.lib.getExe pkgs.nixgl.nixGLIntel} $bin \$@" > $wrapped_bin
           chmod +x $wrapped_bin
          done
        '';
        alacritty = nixGLWrap pkgs.alacritty;
      in
      # See https://nixos.wiki/wiki/Flakes#Output_schema
      {
        apps."home-manager" = mkApp "home-manager";
        # apps."alacritty" = mkApp "alacritty";
        apps."alacritty" = { type = "app"; program = "${pkgs.alacritty}/bin/alacritty"; };
        # This formats the nix files, not the rest of the repo.
        formatter = pkgs.nixpkgs-fmt;
      }
    );
}
