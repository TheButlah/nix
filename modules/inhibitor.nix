{
  pkgs,
  config,
  lib,
  username,
  ...
}:
let
  modname = "inhibitor";
  cfg = config.thebutlah."${modname}";

  inherit (lib)
    mkIf
    mkEnableOption
    mkOption
    ;
in
{
  options.thebutlah.${modname} = {
    enable = mkEnableOption modname;
    builtinName = mkOption {
      type = lib.types.str;
      description = "The name of the builtin keyboard to inhibit";
    };
  };

  config = mkIf cfg.enable {

    environment.systemPackages = with pkgs; [
      inhibitor # disable built-in keeb and other input devices
    ];
    # Set up keyboard services
    # This target just helps abstract over the particular name of the device, and its slightly
    # more flexible than using udev directly.
    # See also: https://pychao.com/2021/02/24/difference-between-partof-and-bindsto-in-a-systemd-unit
    systemd.targets."wireless-keyboard" = {
      description = "active when a wireless keyboard is connected";
      after = [ "dev-corne.device" ];
      bindsTo = [ "dev-corne.device" ]; # kills this unit when the device unit is stopped
    };
    systemd.services."builtin-keyboard-disable" = {
      description = "disables built-in keyboard while active";
      after = [ "wireless-keyboard.target" ];
      bindsTo = [ "wireless-keyboard.target" ];
      wantedBy = [ "wireless-keyboard.target" ];
      path = with pkgs; [ inhibitor ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = "yes";
        ExecStart = "/usr/bin/env inhibitor disable --name \"${cfg.builtinName}\"";
        ExecStop = "/usr/bin/env inhibitor enable --name \"${cfg.builtinName}\"";
      };
    };

  };
}
