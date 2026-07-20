{
  config,
  inputs,
  lib,
  pkgs,
  username,
  mkDisableOption,
  ...
}:
let
  modname = "xremap";
  cfg = config.thebutlah."${modname}";

  inherit (lib)
    mkIf
    mkEnableOption
    ;
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
