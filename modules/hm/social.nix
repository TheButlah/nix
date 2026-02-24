{
  pkgs,
  config,
  lib,
  username,
  ...
}:
let
  modname = "social";
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
    enable = mkEnableOption "social apps";
    isWork = mkEnableOption "work-only mode";
  };

  config = mkIf cfg.enable {
    home.packages =
      with pkgs;
      lib.optionals (!cfg.isWork && isLinux) [
        legcord
      ];

    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    home.stateVersion = "24.11";
  };
}
