{
  pkgs,
  config,
  lib,
  username,
  ...
}:
let
  modname = "displayManager";
  cfg = config.thebutlah."${modname}";

  inherit (lib)
    mkIf
    mkEnableOption
    mkOption
    ;

  windowManagers = {
    niri = rec {
      initialSession = "${pkgs.niri}/bin/niri-session";
      defaultSession = initialSession;
    };
  };
  windowManager = windowManagers.${cfg.windowManager};
in
{
  options.thebutlah.${modname} = {
    enable = mkEnableOption modname;
    windowManager = mkOption {
      type = lib.types.enum (lib.attrNames windowManagers);
      description = "The window manager to launch";
    };
  };

  config = mkIf cfg.enable {
    services.greetd = {
      enable = true;
      useTextGreeter = true; # prevent error messages breaking tty
      settings = {
        initial_session = {
          command = windowManager.initialSession;
          user = username;
        };

        # Fallback greeter
        default_session = {
          command = "${lib.getExe pkgs.greetd.tuigreet} --time --remember --cmd \"${windowManager.defaultSession}\"";
          user = username;
        };
      };
    };
  };
}
