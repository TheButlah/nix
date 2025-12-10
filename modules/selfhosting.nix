{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
let
  modname = "selfhosting";
  # Shorter name to access final settings a
  # user of hello.nix module HAS ACTUALLY SET.
  # cfg is a typical convention.
  cfg = config.thebutlah."${modname}";
in
{
  options.thebutlah.${modname} = {
    enable = mkEnableOption "hello service";
  };

  config = mkIf cfg.enable {
    services.syncthing = {
      enable = true;
      openDefaultPorts = false; # Open ports in the firewall for Syncthing
    };
  };
}
