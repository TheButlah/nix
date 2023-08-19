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
  };

  outputs = { self, nixpkgs, utils, fenix }:
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
      in
      # See https://nixos.wiki/wiki/Flakes#Output_schema
      {
        # I'm using this as a replacement for brew
        packages.default = pkgs.buildEnv {
          name = "my-env";
          paths = [
            # Better than bash
            pkgs.zsh
            # Nice autosuggestions
            pkgs.zsh-autosuggestions
            # best editor
            pkgs.neovim
            # Makes activating project-specific stuff easy
            pkgs.direnv
            # This is missing on mac m1 nix, for some reason. You need it to compile.
            # see https://stackoverflow.com/a/69732679
            pkgs.libiconv
            # Useful for json manipulation
            pkgs.jq
            pkgs.git
            # Used for storing large files in git
            pkgs.git-lfs
            # Service that provides nix caches
            pkgs.cachix
            # Cross compilation
            pkgs.zig

            # 🦀 Cargo Cult 🦀
            # Everything here is rust btw
            rustToolchain
            # awesome prompt
            pkgs.starship
            # Better than tmux, also rust
            pkgs.zellij
            # Speedy grep replacement
            pkgs.ripgrep
            # If I need to do soy development, at least it wont be with shit tools
            pkgs.fnm
            pkgs.cargo-zigbuild
            pkgs.cargo-expand
            pkgs.probe-rs
            pkgs.cargo-binutils
          ];
        };
        # This formats the nix files, not the rest of the repo.
        formatter = pkgs.nixpkgs-fmt;
      }
    );
}
