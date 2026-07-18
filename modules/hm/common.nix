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
  stripSlash = lib.removeSuffix "/";
  homeDirectory = stripSlash (if isDarwin then "/Users/${username}" else "/home/${username}");
in
{

  imports = [
    ./1password.nix
    ./developer.nix
    ./linux.nix
    ./monado.nix
    ./music.nix
    ./social.nix
    ./terminal.nix
    ./wayland.nix
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
  programs.bash = {
    enable = true;
  };

  # terminal emulators
  programs.alacritty = {
    enable = true;
    package = alacritty;
    settings = lib.trivial.importTOML ../../xdg/alacritty.toml;
  };
  programs.wezterm = {
    enable = true;
    extraConfig = builtins.readFile ../../xdg/wezterm.lua;
  };

  xdg.enable = true;
  xdg.configFile = {
    "karabiner/karabiner.json" = {
      source = ../../xdg/karabiner.json;
    };
  };

  programs.ssh.enable = true;
  programs.ssh.enableDefaultConfig = false;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "26.05";
}
