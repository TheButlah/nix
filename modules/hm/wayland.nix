{
  pkgs,
  config,
  lib,
  username,
  ...
}:
let
  modname = "wayland";
  # Shorter name to access final settings a
  # user of hello.nix module HAS ACTUALLY SET.
  # cfg is a typical convention.
  cfg = config.thebutlah."${modname}";

  inherit (pkgs.stdenv) isDarwin;
  inherit (pkgs.stdenv) isLinux;
  homeDirectory = if isDarwin then "/Users/${username}" else "/home/${username}";

  inherit (lib) mkIf mkEnableOption mkDefault;

  # see https://ertt.ca/nix/shell-scripts/
  fromFile = name: path: (pkgs.writeScriptBin name (builtins.readFile path));
  lockscreen = pkgs.writeShellApplication {
    name = "lockscreen";
    runtimeInputs = with pkgs; [
      hyprlock
      procps
    ];
    text = ''
      if pgrep -x hyprlock >/dev/null; then
        exit 0
      fi
      exec hyprlock
    '';
  };
in
# See https://github.com/nix-community/home-manager/issues/414#issuecomment-427163925
{
  options.thebutlah.${modname} = {
    enable = mkEnableOption "wayland ricing";
    suspend = mkEnableOption "suspending on inactivity";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      (fromFile "gnome-color" ../../scripts/gnome-color.sh)
      wl-clipboard
      nautilus # For file picker
      hyprlock
      lockscreen
    ];

    xdg.configFile = {
      "hypr/hyprlock.conf".source = ../../xdg/hyprlock.conf;
      "niri/config.kdl".source =
        pkgs.runCommand "niri-config-checked"
          {
            nativeBuildInputs = [ pkgs.niri ];
          }
          ''
            niri validate --config ${../../xdg/niri.kdl}
            cp ${../../xdg/niri.kdl} $out
          '';
      "swaylock/config".source = ../../xdg/swaylock.config;
      "waybar/config.jsonc".source = ../../xdg/waybar.config.jsonc;
      "waybar/style.css".source = ../../xdg/waybar.style.css;
    };

    programs.anyrun = {
      enable = true;
      config = {
        plugins = [
          "${pkgs.anyrun}/lib/libapplications.so"
        ];

        x = {
          fraction = 0.5;
        };
        y = {
          fraction = 0.3;
        };
        width = {
          fraction = 0.25;
        };
        height = {
          absolute = 1;
        };
        hideIcons = false;
        hidePluginInfo = true;
        # closeOnClick = true;
      };

      # Styling from https://github.com/fufexan/dotfiles/blob/5d5631f475d892e1521c45356805bc9a2d40d6d1/home/programs/anyrun/default.nix
      extraCss = builtins.readFile ../../xdg/anyrun.css;
      extraConfigFiles."applications.ron".text = builtins.readFile ../../xdg/anyrun.applications.ron;
    };

    programs.waybar = {
      enable = true;
      systemd.enable = true;
    };
    services.mako = {
      enable = true;
    };
    programs.hyprlock = {
      enable = true;
    };
    # security.pam.services.hyprlock = { };
    services.swayidle =
      # from https://wiki.nixos.org/wiki/Swayidle
      let
        lock = lib.getExe lockscreen;
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
            timeout = 30; # in seconds
            command = "${pkgs.libnotify}/bin/notify-send 'Locking in 30 seconds' -t 30000";
          }
          {
            timeout = 60;
            command = lock;
          }
          {
            timeout = 60 * 3;
            command = display "off";
            resumeCommand = display "on";
          }
        ]
        ++ lib.optionals cfg.suspend [
          {
            timeout = 60 * 20;
            command = "${pkgs.systemd}/bin/systemctl suspend";
          }

        ];
        events = {
          before-sleep = (display "off") + "; " + lock;
          after-resume = display "on";
          lock = (display "off") + "; " + lock;
          unlock = display "on";
        };
      };
  };
}
