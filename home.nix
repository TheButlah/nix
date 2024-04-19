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
  };
  programs.starship = {
    enable = true;
    settings = lib.trivial.importTOML ./starship.toml;
  };
  programs.alacritty = {
    enable = true;
    package = alacritty;
    settings = lib.trivial.importTOML ./alacritty.toml;
  };
  programs.wezterm = {
    enable = true;
    extraConfig = builtins.readFile ./wezterm.lua;
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
      source = pkgs.fetchgit {
        url = "https://github.com/thebutlah/init.lua";
        sha256 = "sha256-VQEjADyq3K/xBPnXktahLkE0psCgENyHNYxC5fxc2OI=";
      };
    };
  };

  fonts.fontconfig.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

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
