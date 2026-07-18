{
  pkgs,
  config,
  lib,
  username,
  ...
}:
let
  modname = "vpn";
  cfg = config.thebutlah."${modname}";

  inherit (lib)
    mkIf
    mkEnableOption
    mkOption
    ;

  mkDisableOption =
    name:
    mkOption {
      type = lib.types.bool;
      example = true;
      default = true;
      description = "Whether to enable ${name}.";
    };
in
{
  options.thebutlah.${modname} = {
    enable = mkEnableOption modname;
    mullvad = mkDisableOption "mullvad";
    tailscale = mkDisableOption "tailscale";
  };

  config = mkIf cfg.enable {
    services.mullvad-vpn.enable = cfg.mullvad;
    services.tailscale.enable = cfg.tailscale;
  };
}
