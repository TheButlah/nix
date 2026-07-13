{
  pkgs,
  config,
  lib,
  ...
}:
let
  modname = "monado";
  # Shorter name to access final settings a
  # user of hello.nix module HAS ACTUALLY SET.
  # cfg is a typical convention.
  cfg = config.thebutlah."${modname}";

  inherit (pkgs.stdenv) isDarwin;
  inherit (pkgs.stdenv) isLinux;

  inherit (lib) mkIf mkEnableOption mkDefault;

  disableSteamVrPoweron = pkgs.writeShellApplication {
    name = "disableSteamVrPoweron";
    runtimeInputs = with pkgs; [ jq ];
    text = ''
      STEAMHOME="${config.xdg.dataHome}/Steam"
      VR_SETTINGS="$STEAMHOME/config/steamvr.vrsettings"
      if [ -e $VR_SETTINGS ]; then
        tmp="$(mktemp)"
        echo "Found steamvr settings, mutating."
        jq ".power.autoLaunchSteamVROnButtonPress = false" "$VR_SETTINGS" > "$tmp"
        mv "$tmp" "$VR_SETTINGS"
      else
        echo "No steamvr settings found, continuing."
      fi
    '';
  };
in
# See https://github.com/nix-community/home-manager/issues/414#issuecomment-427163925
{
  options.thebutlah.${modname} = {
    enable = mkEnableOption "vr";
    xrizer = mkEnableOption "xrizer";
    opencomposite = mkEnableOption "opencomposite";
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = !(cfg.xrizer && cfg.opencomposite);
        message = "xrizer conflicts with opencomposite (enable only one).";
      }
      {
        assertion = isLinux;
        message = "this module should only be used on linux";
      }
    ];

    home.packages = [ disableSteamVrPoweron ];

    home.activation = {
      # https://wiki.vronlinux.org/docs/fossvr/monado/#disable-steamvr-automatically-starting-whenever-you-turn-on-your-controllers
      disableSteamVrPoweron = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        run ${lib.getExe disableSteamVrPoweron}
      '';
    };

    home.file = {
      "vr.sh" = {
        executable = true;
        source = ../../scripts/vr.sh;
      };
    };

    xdg.enable = true;
    xdg.configFile = {
      "openxr/1/active_runtime.json" = {
        source = "${pkgs.monado}/share/openxr/1/openxr_monado.json";
        force = true;
      };
      "openvr/openvrpaths.vrpath" = mkIf (cfg.opencomposite || cfg.xrizer) (
        let
          steam = "${config.xdg.dataHome}/Steam";
          contents = builtins.toJSON {
            version = 1;
            jsonid = "vrpathreg";

            external_drivers = null;
            config = [ "${steam}/config" ];

            log = [ "${steam}/logs" ];

            runtime =
              lib.optionals cfg.xrizer [
                "${pkgs.xrizer}/lib/xrizer"
              ]
              ++ lib.optionals cfg.opencomposite [
                "${pkgs.opencomposite}/lib/opencomposite"
              ];
          };
        in
        {
          text = contents;
          force = true;
        }
      );
    };
  };

}
