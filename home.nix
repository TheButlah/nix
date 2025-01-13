{ pkgs, lib, username ? "ryan", isWork ? true, isWayland ? false, alacritty ? pkgs.alacritty, ... }:
let
  inherit (pkgs.stdenv) isDarwin;
  inherit (pkgs.stdenv) isLinux;
in
{
  home = {
    username = "${username}";
    homeDirectory = if isDarwin then "/Users/${username}" else "/home/${username}";
    packages = import ./packages/all.nix { inherit pkgs isWork isWayland; };
    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
    shellAliases = {
      cz = "cargo-zigbuild";
      czb = "cargo zigbuild";
      czc = "cargo-zigbuild check";
      czcl = "cargo-zigbuild clippy";

      a64 = "echo aarch64-unknown-linux-gnu";
      x86 = "echo x86_64-unknown-linux-gnu";

    };
  };

  programs.home-manager.enable = true;
  programs.git = {
    enable = true;
    userName = "Ryan Butler";
    userEmail = "thebutlah@gmail.com";
    lfs.enable = true;
    extraConfig = {
      rebase = {
        updateRefs = true;
      };
    };
  };

  # shell stuff
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    enableCompletion = true;
    oh-my-zsh.enable = true;
    initExtra = ''
      set -o vi
      eval "$(fnm env --use-on-cd --shell zsh)"
      export OPENAI_API_KEY="''${OPENAI_API_KEY:-"$(op read --account PJ5RFQLTJNBQDI3OMBJHR3LOZ4 "op://Terminal Secrets/OpenAI API Key/credential")"}"
      export ANTHROPIC_API_KEY="''${ANTHROPIC_API_KEY:-"$(op read --account PJ5RFQLTJNBQDI3OMBJHR3LOZ4 "op://Terminal Secrets/Anthropic API Key/credential")"}"
    '' + (lib.optionalString pkgs.stdenv.isDarwin ''
      eval "$(/opt/homebrew/bin/brew shellenv)"
    '');
    envExtra = ''
    '';
  };
  programs.starship = {
    enable = true;
    settings = lib.trivial.importTOML ./xdg/starship.toml;
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

  # terminal emulators
  programs.alacritty = {
    enable = true;
    package = alacritty;
    settings = lib.trivial.importTOML ./xdg/alacritty.toml;
  };
  programs.wezterm = {
    enable = true;
    extraConfig = builtins.readFile ./xdg/wezterm.lua;
  };
  programs.zellij = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    package = pkgs.unstable.zellij;
  };

  programs.direnv = {
    enable = true;
    enableBashIntegration = true; # see note on other shells below
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  xdg.enable = true;
  xdg.configFile = {
    "nvim" = {
      source = pkgs.fetchFromGitHub {
        owner = "thebutlah";
        repo = "init.lua";
        rev = "d774f01ecfd3edbdfdee606faaff10a9caada0d4";
        hash = "sha256-6PBT/G65s7opzLBa25052X6aZaZOg6zR5H1CUnR686Y=";
      };
    };
    "karabiner/karabiner.json" = {
      source = ./xdg/karabiner.json;
    };
    "mods/mods.yml" = {
      source = ./xdg/mods.yml;
    };
    "zellij/config.kdl" = {
      source = ./xdg/zellij.kdl;
    };
    "atuin/config.toml" = {
      source = ./xdg/atuin.toml;
    };
  };

  fonts.fontconfig.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  programs.ssh.enable = true;
  programs.ssh.matchBlocks =
    let
      defaults = isTrusted: {
        forwardAgent = isTrusted;
        forwardX11 = true;
        forwardX11Trusted = isTrusted;
      };
    in
    {
      "hug" = defaults true // {
        hostname = "huggable.us";
        user = "ryan";
        port = 22;
      };
      "deck" = defaults true // {
        hostname = "deck";
        user = "deck";
      };
      "li-ubuntu-us-east" = defaults true // {
        hostname = "li-ubuntu-us-east.servers.thebutlah.com";
        user = "admin";
      };
      "hil" = defaults true // {
        hostname = "ryan-worldcoin-hil.servers.thebutlah.com";
        port = 222;
        user = "worldcoin";
      };
    };
  # programs.keychain = {
  #   enable = true;
  #   keys = [ "id_ed25519" ];
  # };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.11";
}

# } // (if isLinux then {
#   xdg.desktopEntries = {
#     alacritty = {
#       name = "Alacritty";
#       genericName = "Terminal";
#       exec = "alacritty";
#       terminal = false;
#       categories = [ "System" "TerminalEmulator" ];
#     };
#   };
