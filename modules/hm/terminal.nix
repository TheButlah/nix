{
  pkgs,
  config,
  lib,
  username,
  ...
}:
let
  modname = "terminal";
  # Shorter name to access final settings a
  # user of hello.nix module HAS ACTUALLY SET.
  # cfg is a typical convention.
  cfg = config.thebutlah."${modname}";

  inherit (pkgs.stdenv) isDarwin;
  inherit (pkgs.stdenv) isLinux;
  inherit (lib)
    mkIf
    mkEnableOption
    mkOption
    ;

  homeDirectory = if isDarwin then "/Users/${username}" else "/home/${username}";
  mkDisableOption =
    name:
    mkOption {
      type = lib.types.bool;
      example = true;
      default = true;
      description = "Whether to enable ${name}.";
    };
in
# See https://github.com/nix-community/home-manager/issues/414#issuecomment-427163925
{
  options.thebutlah.${modname} = {
    enable = mkEnableOption "terminal ricing";
    nvim = mkDisableOption "neovim";
  };

  config = mkIf cfg.enable {
    home = {
      sessionVariables = mkIf cfg.nvim {
        EDITOR = "nvim";
        VISUAL = "nvim";
      };
      packages =
        with pkgs;
        [
          # bootstrap
          bash # Macos has an old bash
          cachix # Service that provides nix caches
          coreutils # MacOS uses BSD coreutils, use gnu instead
          curl
          git
          git-lfs
          gnutar # Macos has an old/weird tar
          unzip
          wget
          zsh

          # CLI
          asciinema
          atuin
          b3sum
          bat
          bottom
          dust
          eza
          file
          glow
          htop
          jq
          ripgrep
          shellcheck
          tree
          watch
        ]
        ++ lib.optionals cfg.nvim [
          tree-sitter
          nixfmt
          neovim
        ];
    };

    # shell stuff
    programs.zsh = {
      enable = true;
      autosuggestion.enable = true;
      enableCompletion = true;
      oh-my-zsh.enable = true;
      initContent =
        (lib.optionalString pkgs.stdenv.isDarwin ''
          eval "$(/opt/homebrew/bin/brew shellenv)"
        '')
        + ''
          set -o vi
        '';
      # dotDir = "${config.xdg.configHome}/zsh";
      dotDir = config.home.homeDirectory;
    };

    programs.starship = {
      enable = true;
      settings = lib.trivial.importTOML ../../xdg/starship.toml;
    };
    programs.zoxide = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      options = [ "--cmd cd" ];
    };
    programs.atuin = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      package = pkgs.atuin;
    };
    programs.yazi = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      shellWrapperName = "y";
    };
    programs.zellij = {
      enable = true;
      # enableBashIntegration = true;
      # enableZshIntegration = true;
      package = pkgs.unstable.zellij;
    };
    programs.direnv = {
      enable = true;
      enableBashIntegration = true; # see note on other shells below
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };

    xdg.enable = true;
    xdg.configFile = mkIf cfg.nvim {
      "nvim" = {
        source = pkgs.fetchFromGitHub {
          owner = "thebutlah";
          repo = "init.lua";
          rev = "3f5b470acd81a3931fa761fcd4e9f052aba67673";
          hash = "sha256-T07cbqz4D+U9sSRe42njSu4OBRpMUUJ05gatwkJ9tco=";
        };
      };
      "zellij/config.kdl" = {
        source = ../../xdg/zellij.kdl;
      };
      "atuin/config.toml" = {
        source = ../../xdg/atuin.toml;
      };
    };

    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    home.stateVersion = "24.11";
  };

}
