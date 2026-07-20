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
    nixos-26_05.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixos-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    # For MacOS
    nixpkgs-26_05-darwin.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main";
      inputs.nixpkgs.follows = "nixos-26_05";
    };

    # Provides eachDefaultSystem and other utility functions
    flake-utils.url = "github:numtide/flake-utils";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixos-26_05";
    };

    # Replacement for rustup
    fenix-linux = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixos-26_05";
    };
    fenix-darwin = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs-26_05-darwin";
    };

    # Manages user settings
    home-manager-linux = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixos-26_05";
    };
    home-manager-darwin = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs-26_05-darwin";
    };

    # Provides better GPU support
    nixgl = {
      url = "github:nix-community/nixGL";
      inputs.nixpkgs.follows = "nixos-26_05";
    };

    # Like NixOS, but for darwin
    nix-darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs-26_05-darwin";
    };

    # Builds nix system images
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixos-26_05";
    };

    nixos-apple-silicon = {
      url = "github:nix-community/nixos-apple-silicon";
      inputs.nixpkgs.follows = "nixos-26_05";
    };

    # Rust animated wallpaper
    awww = {
      url = "git+https://codeberg.org/LGFae/awww";
      inputs.nixpkgs.follows = "nixos-26_05";
    };

    # rust keyboard remapper via evdev and uinput
    xremap-flake = {
      url = "github:xremap/nix-flake";
      inputs.nixpkgs.follows = "nixos-26_05";
    };

    niri-flake = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixos-unstable";
      inputs.nixpkgs-stable.follows = "nixos-26_05";
    };

    inhibitor = {
      url = "github:TheButlah/inhibitor";
      inputs.nixpkgs.follows = "nixos-26_05";
    };

    # for work
    kolide-launcher = {
      url = "github:kolide/nix-agent";
      inputs.nixpkgs.follows = "nixos-26_05";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.1.0";
      inputs.nixpkgs.follows = "nixos-26_05";
    };

    comfyui-nix-devshell = {
      url = "github:aldenparker/comfyui-nix-devshell";
      inputs.nixpkgs.follows = "nixos-unstable";
    };

    nixpkgs-xr = {
      url = "github:nix-community/nixpkgs-xr";
      inputs.nixpkgs.follows = "nixos-26_05";
    };
  };

  outputs =
    inputs-raw@{ self, ... }:
    let
      mkInputs = (system: import ./inputs.nix { inherit inputs-raw system; });

      mkPkgs = (
        system:
        let
          inputs = mkInputs system;
        in
        import inputs.nixpkgs {
          inherit system;
          overlays = [
            inputs.niri-flake.overlays.niri
            inputs.nixgl.overlay
            inputs.inhibitor.overlays.${system}.default
            inputs.nixos-apple-silicon.overlays.apple-silicon-overlay
            # (import overlays/mods.nix)
            ((import overlays/unstable.nix) { inherit inputs; })
            (import overlays/karabiner-14.nix)
            (import overlays/libdjinterop.nix)
            (import overlays/direnv-no-check.nix)
            inputs.awww.overlays.default
            inputs.nixpkgs-xr.overlays.default
          ];
          config = {
            allowUnfree = true;
            hardware.enableRedistributableFirmware = true;
          };
          flake = abort "this should be specified in nixos modules, its inert here";
        }
      );

      # All system-specific variables
      forSystem = (
        system:
        let
          inputs = mkInputs system;
          pkgs = mkPkgs system;
          lib = inputs.nixpkgs.lib;
          mkDisableOption =
            name:
            lib.mkOption {
              type = lib.types.bool;
              example = true;
              default = true;
              description = "Whether to enable ${name}.";
            };
          isLinux = pkgs.stdenv.isLinux;
          isDarwin = pkgs.stdenv.isDarwin;
          nixGLWrap =
            pkg:
            pkgs.runCommand "${pkg.name}-nixgl-wrapper" { } ''
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
          inherit
            pkgs
            lib
            mkDisableOption
            inputs
            ;
          alacritty = if isLinux then (nixGLWrap pkgs.alacritty) else pkgs.alacritty;
          wezterm = if isLinux then (nixGLWrap pkgs.wezterm) else pkgs.wezterm;
          tsh17 = pkgs.teleport_17;
          darwin-rebuild = inputs.nix-darwin.outputs.packages.${system}.darwin-rebuild;
        }
      );

      inherit
        (inputs-raw.flake-utils.lib.eachDefaultSystem (system: {
          s = forSystem system;
        }))
        s
        ;

      darwinConfig =
        {
          modulePath,
          username,
          isWork,
          hostname,
          homeManagerCfg,
          readOnlyPkgs ? true,
        }:
        (
          let
            system = "aarch64-darwin";
            inherit (s.${system})
              inputs
              pkgs
              lib
              mkDisableOption
              ;
          in
          inputs.nix-darwin.lib.darwinSystem rec {
            inherit system;
            specialArgs = {
              inherit
                hostname
                username
                inputs
                mkDisableOption
                ;
            };
            modules = [
              modulePath
              # setup home-manager
              inputs.home-manager.darwinModules.home-manager
              {
                home-manager = {
                  useGlobalPkgs = true;
                  useUserPackages = true;
                  # include the home-manager module
                  users.${username} = import homeManagerCfg;
                  extraSpecialArgs = rec {
                    inherit
                      username
                      isWork
                      pkgs
                      inputs
                      mkDisableOption
                      ;
                    inherit (pkgs) alacritty;
                  };
                };
              }
            ]
            ++ lib.optionals isWork [
              # inputs.kolide-launcher.nixosModules.kolide-launcher
            ];
          }
        );

      nixosConfig =
        {
          modulePath,
          username,
          hostname,
          system,
          isWork,
          readOnlyPkgs ? true,
          homeManagerCfg,
        }:
        (
          let
            inherit (s.${system})
              inputs
              pkgs
              lib
              mkDisableOption
              ;
          in
          inputs.nixpkgs.lib.nixosSystem rec {
            specialArgs = {
              inherit
                username
                hostname
                isWork
                inputs
                mkDisableOption
                self
                ;
              modulesPath = "${inputs.nixpkgs}/nixos/modules";
            };
            modules = [
              {
                nixpkgs = {
                  inherit pkgs;
                };
              }
              ./modules/common.nix
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
                    inherit
                      username
                      hostname
                      isWork
                      pkgs
                      inputs
                      mkDisableOption
                      ;
                    inherit (pkgs) alacritty;
                  };
                };
              }
            ]
            ++ lib.optionals readOnlyPkgs [
              inputs.nixpkgs.nixosModules.readOnlyPkgs
            ]
            ++ lib.optionals isWork [
              inputs.kolide-launcher.nixosModules.kolide-launcher
            ];
          }
        );

      nixosAsahiConfig =
        {
          modulePath,
          username,
          hostname,
          isWork,
          homeManagerCfg,
        }:
        (nixosConfig {
          inherit
            modulePath
            username
            hostname
            isWork
            homeManagerCfg
            ;
          system = "aarch64-linux";
          readOnlyPkgs = false;
        });

      homeManagerConfig =
        {
          username,
          hostname,
          system,
          isWork,
          homeManagerCfg,
        }:
        (
          let
            inherit (s.${system})
              inputs
              pkgs
              lib
              mkDisableOption
              ;
          in
          inputs.home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            modules = [
              # ({ modulesPath, ... }: {
              #   # Important! We disable home-manager's module to avoid option
              #   # definition collisions
              #   disabledModules = [ "${modulesPath}/programs/anyrun.nix" ];
              # })
              # inputs.anyrun.homeManagerModules.default
              homeManagerCfg
            ];
            extraSpecialArgs = {
              inherit
                username
                isWork
                inputs
                hostname
                mkDisableOption
                ;
              inherit (s.${system}) alacritty;
            };
          }
        );

    in
    {
      nixosConfigurations."wsl" = nixosConfig {
        username = "ryan";
        system = "x86_64-linux";
        isWork = false;
        modulePath = ./machines/wsl/configuration.nix;
        hostname = "wsl";
      };
      nixosConfigurations."ryan-desktop" = nixosConfig {
        username = "ryan";
        system = "x86_64-linux";
        isWork = false;
        modulePath = ./machines/ryan-desktop/configuration.nix;
        homeManagerCfg = ./machines/ryan-desktop/home.nix;
        hostname = "ryan-desktop";
      };
      nixosConfigurations."ryan-wr" = nixosConfig {
        username = "ryan";
        hostname = "ryan-wr";
        system = "x86_64-linux";
        modulePath = ./machines/ryan-wr/configuration.nix;
        homeManagerCfg = ./machines/ryan-wr/home.nix;
        isWork = false;
      };
      nixosConfigurations."ryan-asahi" = nixosAsahiConfig {
        username = "ryan";
        isWork = false;
        modulePath = ./machines/ryan-asahi/configuration.nix;
        hostname = "ryan-asahi";
        homeManagerCfg = ./machines/ryan-asahi/home.nix;
      };
      nixosConfigurations."li-matrix" = nixosConfig {
        username = "foobar";
        system = "x86_64-linux";
        isWork = false;
        modulePath = ./machines/li-matrix/configuration.nix;
        hostname = "li-matrix";
        homeManagerCfg = ./machines/li-matrix/home.nix;
      };
      darwinConfigurations."ryan-laptop" = darwinConfig {
        username = "ryan";
        isWork = false;
        modulePath = ./machines/ryan-laptop/configuration.nix;
        hostname = "ryan-laptop";
        homeManagerCfg = ./machines/ryan-laptop/home.nix;
      };
      homeConfigurations."ryan@x86" = homeManagerConfig {
        username = "ryan";
        system = "x86_64-linux";
        isWork = false;
        hostname = "x86";
        homeManagerCfg = ./machines/home-headless-developer.nix;
      };
      homeConfigurations."ryan@aarch64" = homeManagerConfig {
        username = "ryan";
        system = "aarch64-linux";
        isWork = false;
        hostname = "aarch64";
        homeManagerCfg = ./machines/home-headless-developer.nix;
      };
      homeConfigurations."vscode@aarch64" = homeManagerConfig {
        username = "vscode";
        system = "aarch64-linux";
        isWork = false;
        hostname = "aarch64";
        homeManagerCfg = ./machines/home-headless-developer.nix;
      };
      homeConfigurations."vscode@x86" = homeManagerConfig {
        username = "vscode";
        system = "x86_64-linux";
        isWork = false;
        hostname = "x86";
        homeManagerCfg = ./machines/home-headless-developer.nix;
      };
      homeConfigurations."vscode@ryan-wr" = homeManagerConfig {
        username = "vscode";
        system = "x86_64-linux";
        isWork = false;
        hostname = "ryan-wr";
        homeManagerCfg = ./machines/home-headless-developer.nix;
      };
      homeConfigurations."deck@steamdeck" = homeManagerConfig {
        username = "deck";
        system = "x86_64-linux";
        isWork = false;
        hostname = "steamdeck";
        homeManagerCfg = ./machines/steamdeck/home.nix;
      };
    }
    //
      # This helper function is used to more easily abstract
      # over the host platform.
      # See https://github.com/numtide/flake-utils#eachdefaultsystem--system---attrs
      inputs-raw.flake-utils.lib.eachDefaultSystem (
        system:
        let
          inherit (s.${system})
            inputs
            pkgs
            alacritty
            wezterm
            tsh17
            darwin-rebuild
            ;
          mkApp = (
            {
              pkg,
              bin ? null,
            }:
            let
              b = if bin == null then pkg.name else bin;
            in
            {
              program = "${pkg}/bin/${b}";
              type = "app";
            }
          );
        in
        # See https://nixos.wiki/wiki/Flakes#Output_schema
        {
          packages = {
            linode = inputs.nixos-generators.nixosGenerate {
              system = "x86_64-linux";
              modules = [
                ./machines/us-east-linode-1/configuration.nix
              ];
              format = "linode";
            };
            chatbox = pkgs.callPackage ./packages/chatbox.nix { };
            svrbsctl = pkgs.callPackage ./packages/svrbsctl.nix { };
          };

          apps."alacritty" = mkApp {
            pkg = alacritty;
            bin = "alacritty";
          };
          apps."darwin-rebuild" = mkApp {
            pkg = darwin-rebuild;
            bin = "darwin-rebuild";
          };
          apps."home-manager" = mkApp {
            pkg = pkgs.home-manager;
            bin = "home-manager";
          };
          apps."tsh17" = mkApp {
            pkg = tsh17;
            bin = "tsh";
          };
          apps."wezterm" = mkApp {
            pkg = wezterm;
            bin = "wezterm";
          };
          packages."disko" = inputs.disko.packages.${system}.disko;
          packages."disko-installer" = inputs.disko.packages.${system}.disko-install;
          packages.tsh17 = tsh17;

          devShells.comfyui = inputs.comfyui-nix-devshell.devShells.${system}.cuda-beta;

          # This formats the nix files, not the rest of the repo.
          formatter = pkgs.nixfmt-tree;
        }
      );
}
