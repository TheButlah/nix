# Common home.nix functionality. most stuff is broken into modules
{
  pkgs,
  config,
  lib,
  username,
  hostname,
  isWork,
  alacritty ? pkgs.alacritty,
  ...
}:
let
  inherit (pkgs.stdenv) isDarwin;
  inherit (pkgs.stdenv) isLinux;
  homeDirectory = if isDarwin then "/Users/${username}" else "/home/${username}";
in
{

  imports = [
    ./modules/hm/1password.nix
    ./modules/hm/developer.nix
    ./modules/hm/linux.nix
    ./modules/hm/monado.nix
    ./modules/hm/music.nix
    ./modules/hm/social.nix
    ./modules/hm/terminal.nix
    ./modules/hm/wayland.nix
  ];

  home = {
    inherit homeDirectory;
    username = "${username}";
    shellAliases = {
      cz = "cargo-zigbuild";
      czb = "cargo zigbuild";
      czc = "cargo-zigbuild check";
      czcl = "cargo-zigbuild clippy";

      a64 = "echo aarch64-unknown-linux-gnu";
      x86 = "echo x86_64-unknown-linux-gnu";
    };

    packages = with pkgs; [
    ];
  };

  programs.home-manager.enable = true;
  programs.git = {
    enable = true;
    lfs.enable = true;
    settings = {
      init = {
        defaultBranch = "main";
      };
      rebase = {
        updateRefs = true;
      };
    };
  };
  programs.gh = {
    enable = true;
    gitCredentialHelper = {
      enable = false;
    };
  };

  # shell stuff
  programs.zsh = {
    enable = true;
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

  xdg.enable = true;
  xdg.configFile = {
    "karabiner/karabiner.json" = {
      source = ./xdg/karabiner.json;
    };
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  programs.ssh.enable = true;
  programs.ssh.enableDefaultConfig = false;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "24.11";
}
