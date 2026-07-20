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
  modname = "systemdBoot";
  cfg = config.thebutlah."${modname}";

  inherit (lib)
    mkIf
    mkEnableOption
    ;
in
{
  imports = [
    inputs.lanzaboote.nixosModules.lanzaboote
  ];

  options.thebutlah.${modname} = {
    enable = mkDisableOption modname;
    secureBoot = mkEnableOption "Secure Boot";
  };

  config = mkIf cfg.enable {
    # https://github.com/nix-community/lanzaboote/blob/747b7912f49e2885090c83364d88cf853a020ac1/docs/QUICK_START.md
    # NOTE: Lanzaboote currently replaces the systemd-boot module.
    # This setting is usually set to true in configuration.nix
    # generated at installation time. So we force it to false
    # for now.
    boot = {
      loader = {
        systemd-boot = {
          enable = !cfg.secureBoot;
          editor = false; # insecure
        };
        timeout = 1; # boot faster
        efi.canTouchEfiVariables = false; # false in asahi
      };
      lanzaboote = {
        enable = cfg.secureBoot;
        pkiBundle = "/var/lib/sbctl";
      };
    };

    environment.systemPackages = with pkgs; [
      sbctl # lanzaboote
    ];
  };
}
