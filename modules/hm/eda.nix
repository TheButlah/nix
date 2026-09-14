{
  pkgs,
  config,
  lib,
  username,
  mkDisableOption,
  ...
}:
let
  modname = "eda";
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
    enable = mkEnableOption "EDA apps";
    kicad = mkDisableOption "kicad";
  };

  config = mkIf cfg.enable {
    home.packages =
      with pkgs;
      lib.optionals cfg.kicad [
        kicad
      ];
  };
}
