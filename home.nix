{ pkgs, lib, inputs, username ? "ryan", isWork ? true, isWayland ? false, alacritty ? pkgs.alacritty, ... }:
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
        rev = "0f741db81dd8eb7cde0740a71ffdad04b79384d7";
        hash = "sha256-IwA4yQ4259+vPr3xAE4svQv6E6IxDk9XaagMN7Bnizk=";
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
  programs.anyrun = {
    enable = true;
    config = {
      x = { fraction = 0.5; };
      y = { fraction = 0.3; };
      width = { fraction = 0.3; };
      hideIcons = false;
      ignoreExclusiveZones = false;
      layer = "overlay";
      hidePluginInfo = false;
      closeOnClick = false;
      showResultsImmediately = false;
      maxEntries = null;

      plugins = [
        # An array of all the plugins you want, which either can be paths to the .so files, or their packages
        inputs.anyrun.packages.${pkgs.system}.applications
      ];
    };

    # Inline comments are supported for language injection into
    # multi-line strings with Treesitter! (Depends on your editor)
    extraCss = /*css */ ''
      .some_class {
        background: red;
      }
    '';

    extraConfigFiles."some-plugin.ron".text = ''
      Config(
        // for any other plugin
        // this file will be put in ~/.config/anyrun/some-plugin.ron
        // refer to docs of xdg.configFile for available options
      )
    '';
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "24.11";
}
