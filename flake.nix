{
  description = "TheButlah's personal dev environment";
  inputs = {
    # Worlds largest repository of linux software
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-23_11.url = "github:NixOS/nixpkgs/nixos-23.11";
    # Provides eachDefaultSystem and other utility functions
    flake-utils.url = "github:numtide/flake-utils";
    # Replacement for rustup
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixgl = {
      url = "github:nix-community/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, nixgl, flake-utils, fenix, home-manager, nix-darwin, ... }:
    let
      mkPkgs = (system: import nixpkgs {
        inherit system;
        overlays = [
          nixgl.overlay
          # (import overlays/mods.nix)
          ((import overlays/unstable.nix) { inherit inputs; })
          ((import overlays/nixpkgs-23_11.nix) { inherit inputs; })
        ];
        config = {
          allowUnfree = true;
        };
      });
      # All system-specific variables
      forSystem = (system:
        let
          pkgs = mkPkgs system;
          isLinux = pkgs.stdenv.isLinux;
          isDarwin = pkgs.stdenv.isDarwin;
          nixGLWrap = pkg: pkgs.runCommand "${pkg.name}-nixgl-wrapper" { } ''
            mkdir $out
            ln -s ${pkg}/* $out
            rm $out/bin
            mkdir $out/bin
            for bin in ${pkg}/bin/*; do
            wrapped_bin=$out/bin/$(basename $bin)
            echo "exec ${pkgs.lib.getExe pkgs.nixgl.auto.nixGLDefault} $bin \$@" > $wrapped_bin
            chmod +x $wrapped_bin
            done
          '';
        in
        {
          inherit pkgs;
          alacritty = if isLinux then (nixGLWrap pkgs.alacritty) else pkgs.alacritty;
          wezterm = if isLinux then (nixGLWrap pkgs.wezterm) else pkgs.wezterm;
          tsh13 = pkgs.nixpkgs-23_11.teleport_13;
          tsh15 = pkgs.teleport_15;
          darwin-rebuild = inputs.nix-darwin.outputs.packages.${system}.darwin-rebuild;
        }
      );
      inherit (flake-utils.lib.eachDefaultSystem (system: { s = forSystem system; })) s;

      darwinConfig = { modulePath, username, isWork, hostname, }: nix-darwin.lib.darwinSystem rec {
        system = "aarch64-darwin";
        specialArgs = { inherit inputs hostname username; };
        modules = [
          modulePath
          # setup home-manager
          home-manager.darwinModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              # include the home-manager module
              users.${username} = import ./home.nix;
              extraSpecialArgs = rec {
                pkgs = s.${system}.pkgs;
                inherit isWork username;
                inherit (pkgs) alacritty;
              };
            };
            # https://github.com/nix-community/home-manager/issues/4026
            users.users.${username}.home = s.${system}.pkgs.lib.mkForce "/Users/${username}";
          }
        ];
      };
      nixosConfig = { modulePath, system, username, hostname, isWork, isWayland, homeManagerCfg ? ./home.nix }: nixpkgs.lib.nixosSystem rec {
        inherit system;
        specialArgs = { inherit inputs username hostname isWork isWayland; pkgs = s.${system}.pkgs; modulesPath = "${nixpkgs}/nixos/modules"; };
        modules = [
          modulePath
          # setup home-manager
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              # include the home-manager module
              users.${username} = import homeManagerCfg;
              extraSpecialArgs = rec {
                pkgs = s.${system}.pkgs;
                inherit username isWork isWayland;
                inherit (pkgs) alacritty;
              };
            };
            # https://github.com/nix-community/home-manager/issues/4026
            # users.users.${username}.home = s.${system}.pkgs.lib.mkForce "/Users/${username}";
          }
        ];
      };
      hilConfig = { hostname }: nixosConfig {
        system = "x86_64-linux";
        username = "worldcoin";
        isWork = true;
        modulePath = ./machines/${hostname}/configuration.nix;
        hostname = "${hostname}";
        isWayland = false;
        homeManagerCfg = ./home-hil.nix;
      };
    in
    {

      darwinConfigurations."ryan-laptop" = darwinConfig {
        username = "ryan";
        isWork = false;
        modulePath = ./machines/ryan-laptop/configuration.nix;
        hostname = "ryan-laptop";
      };
      darwinConfigurations."Ryan-Butler" = darwinConfig {
        username = "ryan.butler";
        isWork = true;
        modulePath = ./machines/ryan-laptop/configuration.nix;
        hostname = "Ryan-Butler";
      };
      nixosConfigurations."ryan-worldcoin-hil" = hilConfig {
        hostname = "ryan-worldcoin-hil";
      };
      nixosConfigurations."worldcoin-hil-munich-0" = hilConfig {
        hostname = "worldcoin-hil-munich-0";
      };
      nixosConfigurations."worldcoin-hil-munich-1" = hilConfig {
        hostname = "worldcoin-hil-munich-1";
      };
      homeConfigurations."ryan@ryan-laptop" = home-manager.lib.homeManagerConfiguration {
        pkgs = s."aarch64-darwin".pkgs;
        modules = [ ./home.nix ];
        extraSpecialArgs = { isWork = false; username = "ryan"; inherit (s."aarch64-darwin") alacritty; };
      };
      homeConfigurations."ryan@ryan-worldcoin-asahi" = home-manager.lib.homeManagerConfiguration {
        pkgs = s."aarch64-linux".pkgs;
        modules = [ ./home.nix ];
        extraSpecialArgs = { isWork = true; username = "ryan"; isWayland = true; inherit (s."aarch64-linux") alacritty; };
      };
      homeConfigurations."ryan.butler@ryan-worldcoin" = home-manager.lib.homeManagerConfiguration {
        pkgs = s."aarch64-darwin".pkgs;
        modules = [ ./home.nix ];
        extraSpecialArgs = { isWork = true; username = "ryan.butler"; inherit (s."aarch64-darwin") alacritty; };
      };
      homeConfigurations."ryan@ryan-worldcoin-hil" = home-manager.lib.homeManagerConfiguration {
        pkgs = s."x86_64-linux".pkgs;
        modules = [ ./home.nix ];
        extraSpecialArgs = { isWork = true; username = "ryan"; isWayland = false; inherit (s."x86_64-linux") alacritty; };
      };
    } //
    # This helper function is used to more easily abstract
    # over the host platform.
    # See https://github.com/numtide/flake-utils#eachdefaultsystem--system---attrs
    flake-utils.lib.eachDefaultSystem (system:
      let
        inherit (s.${system}) pkgs alacritty wezterm tsh13 tsh15 darwin-rebuild;
        mkApp = ({ pkg, bin ? null }:
          let
            b = if bin == null then pkg.name else bin;
          in
          { program = "${pkg}/bin/${b}"; type = "app"; });
      in
      # See https://nixos.wiki/wiki/Flakes#Output_schema
      {
        apps."home-manager" = mkApp { pkg = pkgs.home-manager; bin = "home-manager"; };
        apps."darwin-rebuild" = mkApp { pkg = darwin-rebuild; bin = "darwin-rebuild"; };
        apps."tsh13" = mkApp { pkg = tsh13; bin = "tsh"; };
        packages.tsh13 = tsh13;
        apps."tsh15" = mkApp { pkg = tsh15; bin = "tsh"; };
        packages.tsh15 = tsh15;
        apps."alacritty" = mkApp { pkg = alacritty; bin = "alacritty"; };
        apps."wezterm" = mkApp { pkg = wezterm; bin = "wezterm"; };

        # This formats the nix files, not the rest of the repo.
        formatter = pkgs.nixpkgs-fmt;
      }
    );
}
