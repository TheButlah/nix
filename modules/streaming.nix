{
  pkgs,
  config,
  lib,
  username,
  ...
}:
let
  modname = "streaming";
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
    droidcam = mkDisableOption "droidcam";
  };

  config = mkIf cfg.enable {
    programs.droidcam.enable = cfg.droidcam;
    programs.obs-studio = {
      enable = true;
      enableVirtualCamera = true;
      plugins = [
        # pkgs.obs-studio-plugins.wlrobs
      ]
      ++ lib.optionals cfg.droidcam [
        pkgs.obs-studio-plugins.droidcam-obs
      ];
    };
  };
}
