{
  pkgs,
  config,
  lib,
  username,
  mkDisableOption,
  ...
}:
let
  modname = "bluetooth";
  cfg = config.thebutlah."${modname}";

  inherit (lib)
    mkIf
    mkEnableOption
    mkOption
    ;
in
{
  options.thebutlah.${modname} = {
    enable = mkDisableOption modname;
    onBoot = mkDisableOption "on boot";
  };

  config = mkIf cfg.enable {
    hardware.bluetooth.enable = true; # enables support for Bluetooth
    hardware.bluetooth.powerOnBoot = cfg.onBoot; # powers up the default Bluetooth controller on boot
  };
}
