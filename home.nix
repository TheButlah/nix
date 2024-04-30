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
  };

  programs.home-manager.enable = true;
  programs.git = {
    enable = true;
    userName = "Ryan Butler";
    userEmail = "thebutlah@gmail.com";
    lfs.enable = true;
  };
  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    oh-my-zsh.enable = true;
    initExtra = ''
      set -o vi
    '';
    envExtra = ''
      export OPENAI_API_KEY="''${OPENAI_API_KEY:-"$(op read --account PJ5RFQLTJNBQDI3OMBJHR3LOZ4 "op://Personal/OpenAI API Key/credential")"}"
    '';
  };
  programs.starship = {
    enable = true;
    settings = lib.trivial.importTOML ./xdg/starship.toml;
  };
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
    enableZshIntegration = true;
    enableBashIntegration = true;
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
        rev = "ea6cc4e6f98cd99e7ab26dd1a750d34919adc454";
        hash = "sha256-P6rhEBTOuXf28L+0EYtdyt3q0bxSKnNFFmuykPpFrQ0=";
      };
    };
    "karabiner/karabiner.json" = {
      source = ./xdg/karabiner.json;
    };
    "mods/mods.yml" = {
      source = ./xdg/mods.yml;
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
        user = "ryan";
      };
      "hil" = defaults true // {
        hostname = "ryan-worldcoin-hil.servers.thebutlah.com";
        port = 222;
        user = "ryan";
      };
    };

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
