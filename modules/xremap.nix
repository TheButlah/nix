{
  pkgs,
  config,
  lib,
  username,
  inputs,
  ...
}:
let
  modname = "xremap";
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
  imports = [
    inputs.xremap-flake.nixosModules.default
  ];

  options.thebutlah.${modname} = {
    enable = mkDisableOption modname;
  };

  config = mkIf cfg.enable {
    services.xremap = {
      enable = true;
      userName = "${username}";
      serviceMode = "user";
      withWlroots = true;
      yamlConfig = builtins.readFile ../xdg/xremap.yaml;
    };
  };
}
