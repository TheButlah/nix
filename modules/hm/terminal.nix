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
  homeDirectory = if isDarwin then "/Users/${username}" else "/home/${username}";

  inherit (lib) mkIf mkEnableOption mkDefault;
in
# See https://github.com/nix-community/home-manager/issues/414#issuecomment-427163925
{
  options.thebutlah.${modname} = {
    enable = mkEnableOption "terminal ricing";
    nvim = mkEnableOption "neovim";
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
          b3sum
          bat
          bottom
          dust
          eza
          file
          glow
          htop
          jq
          neofetch
          shellcheck
          tree
          watch
          ripgrep
        ]
        ++ lib.optionals cfg.nvim [
          tree-sitter
          nixfmt
        ];
    };

    # shell stuff
    programs.zsh = {
      autosuggestion.enable = true;
      enableCompletion = true;
      oh-my-zsh.enable = true;
      initContent =
        (lib.optionalString pkgs.stdenv.isDarwin ''
          eval "$(/opt/homebrew/bin/brew shellenv)"
        '')
        + ''
          set -o vi

          eval "$(fnm env --use-on-cd --shell zsh)"

          export BUN_INSTALL="$HOME/.bun"
          export PATH="$BUN_INSTALL/bin:$PATH"

          export PATH="$PATH:${homeDirectory}/.dotnet/tools"
        '';
      envExtra = '''';
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
      package = pkgs.unstable.atuin;
    };
    programs.yazi = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
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
          rev = "ed2ea25388905636bb4ca575fa5b6e4215a9d5fa";
          hash = "sha256-Klv7MYPCUKFCX8D7kqLGKsPX5MPTpIOZmqxqihpJs28=";
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
