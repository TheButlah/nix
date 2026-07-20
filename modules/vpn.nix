{
  pkgs,
  config,
  lib,
  username,
  mkDisableOption,
  ...
}:
let
  modname = "vpn";
  cfg = config.thebutlah."${modname}";

  inherit (lib)
    mkIf
    mkEnableOption
    ;
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
