{
  config,
  inputs,
  lib,
  ...
}:
let
  cfg = config.thebutlah.kolide;
in
{
  imports = [
    inputs.kolide-launcher.nixosModules.kolide-launcher
  ];

  options.thebutlah.kolide.enable = lib.mkEnableOption "Kolide launcher";

  config = lib.mkIf cfg.enable {
    services.kolide-launcher.enable = true;
  };
}
