# Linux-only configuration
{ pkgs, lib, inputs, username, hostname, isWayland, isGui, isWork ? true, alacritty ? pkgs.alacritty, ... }:
lib.mkIf pkgs.stdenv.isLinux {
  xdg.configFile = {
    "niri/config.kdl" = {
      source = ./xdg/niri.kdl;
    };
    "waybar/style.css".source = ./xdg/waybar.style.css;
    "waybar/config.jsonc".source = ./xdg/waybar.config.jsonc;
    "swaylock/config".source = ./xdg/swaylock.config;
  };

  programs.anyrun = {
    enable = isGui && isWayland;
    config = {
      plugins = [
        "${pkgs.anyrun}/lib/libapplications.so"
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
  services.swayidle =
    # from https://wiki.nixos.org/wiki/Swayidle
    let
      # Lock command
      lock = "${pkgs.swaylock-effects}/bin/swaylock --daemonize";
      # TODO: modify "display" function based on your window manager
      # Sway
      # display = status: "swaymsg 'output * power ${status}'"; \
      # Hyprland
      # display = status: "hyprctl dispatch dpms ${status}";
      # Niri
      display = status: "${pkgs.niri}/bin/niri msg action power-${status}-monitors";
    in
    {
      enable = true;
      timeouts = [
        {
          timeout = 60 * 2; # in seconds
          command = "${pkgs.libnotify}/bin/notify-send 'Locking in 30 seconds' -t 30000";
        }
        {
          timeout = 60 * 2 + 30;
          command = lock;
        }
        {
          timeout = 60 * 3;
          command = display "off";
          resumeCommand = display "on";
        }
        # {
        #   timeout = 60 * 20;
        #   command = "${pkgs.systemd}/bin/systemctl suspend";
        # }
      ];
      events = [
        {
          event = "before-sleep";
          # adding duplicated entries for the same event may not work
          command = (display "off") + "; " + lock;
        }
        {
          event = "after-resume";
          command = display "on";
        }
        {
          event = "lock";
          command = (display "off") + "; " + lock;
        }
        {
          event = "unlock";
          command = display "on";
        }
      ];
    };

  # note: run `spotifyd authenticate` to login.
  services.spotifyd = {
    enable = true;
  };
}
