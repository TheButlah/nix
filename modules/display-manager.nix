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
    mkMerge
    ;

  windowManagers = {
    niri = rec {
      initialSession = "${config.programs.niri.package}/bin/niri-session";
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

  config = mkIf cfg.enable (mkMerge [
    {
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
            command = "${lib.getExe pkgs.tuigreet} --time --remember --cmd ${windowManager.defaultSession}";
            user = "greeter";
          };
        };
      };

      security.pam.services.hyprlock = { };
    }

    (mkIf (cfg.windowManager == "niri") {
      programs.niri.enable = true;

      # niri-session re-execs itself through an unqualified `bash`, but greetd's
      # default service PATH does not include bash.
      systemd.services.greetd.path = [ pkgs.bash ];

      # NixOS otherwise injects a stripped PATH via Environment= on the niri.service
      # unit which shadows the imported user-manager PATH. Disabling the default
      # lets niri inherit the full PATH set up by niri-session.
      systemd.user.services.niri.enableDefaultPath = false;

      environment.systemPackages = with pkgs; [
        # xwayland-satellite-stable
        xwayland-satellite
      ];
    })
  ]);
}
