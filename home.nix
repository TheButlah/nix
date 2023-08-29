{ pkgs, lib, config, username, ... }:
let
  nvim_cfg = pkgs.fetchgit {
    url = "https://github.com/thebutlah/init.lua";
    sha256 = "sha256-0Hea7q2OaB6Gld5n5MztxIE4wJapCAjSPD4Cz7+Z044=";
  };
in
{
  home = {
    inherit username;
    homeDirectory = "/home/${username}";
    packages = import ./packages/all.nix { inherit pkgs; };
    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
  };

  programs.home-manager.enable = true;
  programs.git = {
    enable = true;
    userName = "Ryan Butler";
    userEmail = "thebutlah" + /* This is done to avoid spam */ "@gmail.com";
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
  programs.wezterm = {
    enable = true;
    extraConfig = builtins.readFile ./wezterm.lua;
  };
  programs.zellij = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
  };
  programs.direnv.enable = true;

  xdg.enable = true;
  xdg.configFile = {
    # Raw symlink to the plugin manager lock file, so that it stays writeable
    "nvim/lazy-lock.json".source = config.lib.file.mkOutOfStoreSymlink "${nvim_cfg}/lazy-lock.json";
    "nvim" = {
      source = nvim_cfg;
    };
  };

  fonts.fontconfig.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.05";
}
