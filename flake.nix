{
  description = "TheButlah's personal dev environment";
  inputs = {
    # For the absolute best possible caching, we use nixos-* on linux and 
    # nixpkgs-*-darwin on mac. This makes the flake inputs section a *LOT* more
    # verbose, but it is worth the hassle to not have to recompile LLVM.
    #
    # Read more here:
    # https://discourse.nixos.org/t/which-nixpkgs-stable-tag-for-nixos-and-darwin-together/32796/3

    # For Linux
    nixos-24_11.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixos-23_11.url = "github:NixOS/nixpkgs/nixos-23.11";
    nixos-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    # For MacOS
    nixpkgs-24_11-darwin.url = "github:NixOS/nixpkgs/nixpkgs-24.11-darwin";
    nixpkgs-23_11-darwin.url = "github:NixOS/nixpkgs/nixpkgs-23.11-darwin";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # Provides eachDefaultSystem and other utility functions
    flake-utils.url = "github:numtide/flake-utils";

    # Replacement for rustup
    fenix-linux = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixos-24_11";
    };
    fenix-darwin = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs-24_11-darwin";
    };

    # Manages user settings
    home-manager-linux = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixos-24_11";
    };
    home-manager-darwin = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs-24_11-darwin";
    };
    home-manager-linux-unstable = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixos-unstable";
    };

    # Provides better GPU support
    nixgl = {
      url = "github:nix-community/nixGL";
      inputs.nixpkgs.follows = "nixos-24_11";
    };

    # Like NixOS, but for darwin
    nix-darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-24.11";
      inputs.nixpkgs.follows = "nixpkgs-24_11-darwin";
    };

    # Builds nix system images
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixos-24_11";
    };

    nixos-apple-silicon = {
      url = "github:tpwrules/nixos-apple-silicon";
      inputs.nixpkgs.follows = "nixos-unstable";
    };

    # Rust animated wallpaper
    swww = {
      url = "github:LGFae/swww";
      inputs.nixpkgs.follows = "nixos-unstable";
    };

    # Rust app launcher
    anyrun = {
      url = "github:anyrun-org/anyrun";
      inputs.nixpkgs.follows = "nixos-unstable";
    };

    # rust keyboard remapper via evdev and uinput
    xremap-flake = {
      url = "github:xremap/nix-flake";
      inputs.nixpkgs.follows = "nixos-unstable";
    };

    niri-flake = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixos-unstable";
      inputs.nixpkgs-stable.follows = "nixos-24_11";
    };
  };

  outputs = inputs-raw:
    let
      mkInputs = (system: import ./inputs.nix { inherit inputs-raw system; });
    in
    let
      mkPkgs = (system:
        let
          inputs = mkInputs system;
        in
        import inputs.nixpkgs {
          inherit system;
          overlays = [
            inputs.nixgl.overlay
            # (import overlays/mods.nix)
            ((import overlays/unstable.nix) { inherit inputs; })
            ((import overlays/nixpkgs-23_11.nix) { inherit inputs; })
            (import overlays/karabiner-14.nix)
          ];
          config = {
            allowUnfree = true;
          };
        });
      # All system-specific variables
      forSystem = (system:
        let
          inputs = mkInputs system;
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
        # These are instantiated once per-system. So anything that should be per-system
          # should go here, for later reuse.
          # This is more efficient than instantiating it ad-hoc.
        {
          inherit pkgs inputs;
          alacritty = if isLinux then (nixGLWrap pkgs.alacritty) else pkgs.alacritty;
          wezterm = if isLinux then (nixGLWrap pkgs.wezterm) else pkgs.wezterm;
          tsh13 = pkgs.nixpkgs-23_11.teleport_13;
          tsh15 = pkgs.teleport_15;
          darwin-rebuild = inputs.nix-darwin.outputs.packages.${system}.darwin-rebuild;
        }
      );
      inherit (inputs-raw.flake-utils.lib.eachDefaultSystem (system: { s = forSystem system; })) s;

      darwinConfig = { modulePath, username, isWork, hostname, }: (
        let
          system = "aarch64-darwin";
          inputs = s.${system}.inputs;
          pkgs = s.${system}.pkgs;
        in
        inputs.nix-darwin.lib.darwinSystem rec {
          inherit system;
          specialArgs = { inherit hostname username inputs; };
          modules = [
            modulePath
            # setup home-manager
            inputs.home-manager.darwinModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                # include the home-manager module
                users.${username} = import ./home.nix;
                extraSpecialArgs = rec {
                  inherit isWork username pkgs inputs hostname;
                  inherit (pkgs) alacritty;
                };
              };
              # https://github.com/nix-community/home-manager/issues/4026
              users.users.${username}.home = pkgs.lib.mkForce "/Users/${username}";
            }
          ];
        }
      );
      nixosConfig = { modulePath, system, username, hostname, isWork, isWayland, homeManagerCfg ? ./home.nix }: (
        let
          inputs = s.${system}.inputs;
          pkgs = s.${system}.pkgs;
        in
        inputs.nixpkgs.lib.nixosSystem rec {
          inherit system;
          specialArgs = { inherit username hostname isWork isWayland inputs pkgs; modulesPath = "${inputs.nixpkgs}/nixos/modules"; };
          modules = [
            modulePath
            # setup home-manager
            inputs.home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                # include the home-manager module
                users.${username} = import homeManagerCfg;
                extraSpecialArgs = rec {
                  inherit username isWork isWayland pkgs inputs hostname;
                  inherit (pkgs) alacritty;
                };
              };
              # https://github.com/nix-community/home-manager/issues/4026
              # users.users.${username}.home = s.${system}.pkgs.lib.mkForce "/Users/${username}";
            }
          ];
        }
      );
      nixosAsahiConfig = { modulePath, username, hostname, isWork, homeManagerCfg ? ./home.nix }: (
        let
          system = "aarch64-linux";
          inputs = s.${system}.inputs;
          pkgs = s.${system}.pkgs;
          isWayland = true;
        in
        inputs.nixpkgs-unstable.lib.nixosSystem rec {
          inherit system;
          specialArgs = { inherit username hostname isWork isWayland inputs; modulesPath = "${inputs.nixpkgs-unstable}/nixos/modules"; };
          modules = [
            modulePath
            {
              nixpkgs.config.allowUnfree = true;
              nixpkgs.overlays = [ inputs.niri-flake.overlays.niri ];
            }
            # setup home-manager
            # inputs.home-manager-unstable.nixosModules.home-manager
            # {
            #   home-manager = {
            #     useGlobalPkgs = true;
            #     useUserPackages = true;
            #     # include the home-manager module
            #     users.${username} = import homeManagerCfg;
            #     extraSpecialArgs = rec {
            #       inherit username isWork isWayland pkgs;
            #       inherit (pkgs) alacritty;
            #     };
            #   };
            #   # https://github.com/nix-community/home-manager/issues/4026
            #   # users.users.${username}.home = s.${system}.pkgs.lib.mkForce "/Users/${username}";
            # }
          ];
        }
      );
      homeManagerConfig = { username, hostname, system, isWork, isWayland ? false }: (
        let
          inputs = s.${system}.inputs;
          pkgs = s.${system}.pkgs;
        in
        inputs.home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            ./home.nix
            inputs.anyrun.homeManagerModules.default
          ];
          extraSpecialArgs = {
            inherit username isWayland isWork inputs hostname;
            inherit (s.${system}) alacritty;
          };
        }
      );
    in
    {
      nixosConfigurations."ryan-asahi" = nixosAsahiConfig {
        username = "ryan";
        isWork = false;
        modulePath = ./machines/ryan-asahi/configuration.nix;
        hostname = "ryan-asahi";
      };
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
      homeConfigurations."vscode" = homeManagerConfig {
        username = "vscode";
        system = "aarch64-linux";
        isWork = true;
        hostname = "vscode@vscode"; # TODO: is this right?
      };
      homeConfigurations."ryan@ryan-laptop" = homeManagerConfig {
        username = "ryan";
        system = "aarch64-darwin";
        isWork = false;
        isWayland = false;
        hostname = "ryan-laptop";
      };
      homeConfigurations."ryan@ryan-asahi" = homeManagerConfig
        {
          username = "ryan";
          system = "aarch64-linux";
          isWork = false;
          isWayland = true;
          hostname = "ryan-asahi";
        };
      homeConfigurations."ryan.butler@ryan-worldcoin" = homeManagerConfig {
        username = "ryan.butler";
        system = "aarch64-darwin";
        isWork = true;
        isWayland = false;
        hostname = "ryan-worldcoin";
      };
      homeConfigurations."ryan@ryan-worldcoin-asahi" = homeManagerConfig {
        username = "ryan";
        system = "aarch64-linux";
        isWork = true;
        isWayland = true;
        hostname = "ryan-worldcoin-asahi";
      };
      homeConfigurations."ryan.butler@ryan-wld-darter" = homeManagerConfig {
        username = "ryan.butler";
        system = "x86_64-linux";
        isWork = true;
        isWayland = true;
        hostname = "ryan-wld-darter";
      };
    } //
    # This helper function is used to more easily abstract
    # over the host platform.
    # See https://github.com/numtide/flake-utils#eachdefaultsystem--system---attrs
    inputs-raw.flake-utils.lib.eachDefaultSystem
      (system:
        let
          inherit (s.${system}) inputs pkgs alacritty wezterm tsh13 tsh15 darwin-rebuild;
          mkApp = ({ pkg, bin ? null }:
            let
              b = if bin == null then pkg.name else bin;
            in
            { program = "${pkg}/bin/${b}"; type = "app"; });
        in
        # See https://nixos.wiki/wiki/Flakes#Output_schema
        {
          packages.linode = inputs.nixos-generators.nixosGenerate {
            system = "x86_64-linux";
            modules = [
              ./machines/us-east-linode-1/configuration.nix
            ];
            format = "linode";
          };

          apps."alacritty" = mkApp { pkg = alacritty; bin = "alacritty"; };
          apps."darwin-rebuild" = mkApp { pkg = darwin-rebuild; bin = "darwin-rebuild"; };
          apps."home-manager" = mkApp { pkg = pkgs.home-manager; bin = "home-manager"; };
          apps."tsh13" = mkApp { pkg = tsh13; bin = "tsh"; };
          apps."tsh15" = mkApp { pkg = tsh15; bin = "tsh"; };
          apps."wezterm" = mkApp { pkg = wezterm; bin = "wezterm"; };
          packages.tsh13 = tsh13;
          packages.tsh15 = tsh15;

          # This formats the nix files, not the rest of the repo.
          formatter = pkgs.nixpkgs-fmt;
        }
      );
}
