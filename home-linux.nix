# Linux-only configuration
{ pkgs, lib, inputs, username, hostname, isWayland, isGui, isWork ? true, alacritty ? pkgs.alacritty, ... }:
lib.mkIf pkgs.stdenv.isLinux {
  xdg.configFile = {
    "niri/config.kdl" = {
      source = ./xdg/niri.kdl;
    };
    "waybar/style.css".source = ./xdg/waybar.style.css;
    "waybar/config.jsonc".source = ./xdg/waybar.config.jsonc;
  };

  programs.anyrun = {
    enable = isGui && isWayland;
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

  programs.waybar = {
    enable = isGui && isWayland;
    systemd.enable = true;
  };
  services.mako = {
    enable = isGui && isWayland;
  };

  # note: run `spotifyd authenticate` to login.
  services.spotifyd = {
    enable = true;
  };
}
