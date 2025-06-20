{ pkgs, lib, inputs, username, hostname, isWork ? true, isWayland ? false, alacritty ? pkgs.alacritty, ... }:
let
  inherit (pkgs.stdenv) isDarwin;
  inherit (pkgs.stdenv) isLinux;
  homeDirectory = if isDarwin then "/Users/${username}" else "/home/${username}";
  op = rec {
    acct = {
      tfh = "72J3ELVKX5BTPKT44JPHXUD6AM";
      me = "PJ5RFQLTJNBQDI3OMBJHR3LOZ4";
    };
    openaiApiKey =
      if isWork then {
        acct = acct.tfh;
        url = "op://Engineering/Orb SW OpenAI API Key/credential";
      } else {
        acct = acct.me;
        url = "op://Terminal Secrets/OpenAI API Key/credential";
      };
    anthropicApiKey =
      if isWork then {
        acct = acct.tfh;
        url = "op://Engineering/Orb SW Anthropic API Key/credential";
      } else {
        acct = acct.me;
        url = "op://Terminal Secrets/Anthropic API Key/credential";
      };
  };
in
{
  home = {
    inherit homeDirectory;
    username = "${username}";
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
    initExtra = (lib.optionalString pkgs.stdenv.isDarwin ''
      eval "$(/opt/homebrew/bin/brew shellenv)"
    '') + ''
      set -o vi

      eval "$(fnm env --use-on-cd --shell zsh)"

      export BUN_INSTALL="$HOME/.bun"
      export PATH="$BUN_INSTALL/bin:$PATH"

      export PATH="$PATH:${homeDirectory}/.dotnet/tools"

      export OPENAI_API_KEY="''${OPENAI_API_KEY:-"$(op read --account "${op.openaiApiKey.acct}" "${op.openaiApiKey.url}")"}"
      export ANTHROPIC_API_KEY="''${ANTHROPIC_API_KEY:-"$(op read --account "${op.anthropicApiKey.acct}" "${op.anthropicApiKey.url}")"}"
    '';
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
  xdg.configFile = {
    "nvim" = {
      source = pkgs.fetchFromGitHub {
        owner = "thebutlah";
        repo = "init.lua";
        rev = "2c3c458325dbe9ee46793d92cea4c541e3c2babd";
        hash = "sha256-MOtj/lCK36oTmnY2HxCLSW6LnzZ5jheaK34EUlKC2qs=";
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
    "niri/config.kdl" = {
      source = ./xdg/niri.kdl;
    };
    "waybar/style.css".source = ./xdg/waybar.style.css;
    "waybar/config.jsonc".source = ./xdg/waybar.config.jsonc;
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
      "i-* mi-*" = defaults true // {
        proxyCommand = "sh -c \"aws ssm start-session --target %h --document-name AWS-StartSSHSession --parameters 'portNumber=%p'\"";
      };
    };
  # programs.keychain = {
  #   enable = true;
  #   keys = [ "id_ed25519" ];
  # };

  programs.waybar = {
    enable = isLinux;
    systemd.enable = true;
  };
  services.mako = {
    enable = isLinux;
  };

  # note: run `spotifyd authenticate` to login.
  services.spotifyd = {
    enable = isLinux;
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "24.11";
} // lib.optionalAttrs isLinux {
  programs.anyrun = {
    enable = true;
    config = {
      plugins = [
        # An array of all the plugins you want, which either can be paths to the .so files, or their packages
        inputs.anyrun.packages.${pkgs.system}.applications
      ];

      # x = { fraction = 0.5; };
      y = { fraction = 0.3; };
      width = { fraction = 0.25; };
      hideIcons = false;
      closeOnClick = true;
    };

    # Styling from https://github.com/fufexan/dotfiles/blob/5d5631f475d892e1521c45356805bc9a2d40d6d1/home/programs/anyrun/default.nix
    extraCss = builtins.readFile ./xdg/anyrun.css;
  };
}
