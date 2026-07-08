{
  pkgs,
  config,
  lib,
  username,
  ...
}:
let
  modname = "music";
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
      ];

    # note: run `spotifyd authenticate` to login.
    services.spotifyd.enable = isLinux;
  };
}
