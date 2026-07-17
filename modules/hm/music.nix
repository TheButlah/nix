{
  pkgs,
  config,
  lib,
  hostname,
  username,
  hostSystem,
  ...
}:
let
  modname = "music";
  system = pkgs.stdenv.hostPlatform.system;
  # Shorter name to access final settings a
  # user of hello.nix module HAS ACTUALLY SET.
  # cfg is a typical convention.
  cfg = config.thebutlah."${modname}";

  inherit (pkgs.stdenv) isDarwin;
  inherit (pkgs.stdenv) isLinux;
  homeDirectory = if isDarwin then "/Users/${username}" else "/home/${username}";

  inherit (lib)
    mkIf
    mkEnableOption
    ;
in
{
  options.thebutlah.${modname} = {
    enable = mkEnableOption "music apps";
    mixxx = mkEnableOption "mixxx";
  };

  config = mkIf cfg.enable {
    home.packages =
      with pkgs;
      lib.optionals cfg.mixxx [
        mixxx
      ]
      ++ lib.optionals (system == "x86_64-linux") [
        spotify
      ];

    # services.spotifyd = {
    #   enable = (system == "aarch64-linux");
    #   settings.global = {
    #     backend = "pulseaudio";
    #     # device_name = hostname;
    #     # device_type = "computer";
    #     disable_discovery = false;
    #     zeroconf_port = 57621;
    #   };
    # };
  };
}
