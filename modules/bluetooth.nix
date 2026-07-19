{
  pkgs,
  config,
  lib,
  username,
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
    onBoot = mkDisableOption "on boot";
  };

  config = mkIf cfg.enable {
    hardware.bluetooth.enable = true; # enables support for Bluetooth
    hardware.bluetooth.powerOnBoot = cfg.onBoot; # powers up the default Bluetooth controller on boot
  };
}
