{
  pkgs,
  config,
  lib,
  username,
  ...
}:
let
  modname = "monado";
  cfg = config.thebutlah."${modname}";

  inherit (lib)
    mkIf
    mkEnableOption
    ;

in
{
  options.thebutlah.${modname} = {
    enable = mkEnableOption modname;
  };

  config = mkIf cfg.enable {
    services.monado = {
      enable = true;
      defaultRuntime = true; # Register as default OpenXR runtime
      highPriority = true;
    };
    systemd.user.services.monado.environment = {
      # IPC_EXIT_ON_DISCONNECT = "1"; # stop monado when all xr apps close
      STEAMVR_LH_ENABLE = "1"; # Requires running room setup in steamvr at least once
      XRT_COMPOSITOR_COMPUTE = "1"; # 1 causes it to crash when using simulated HMDs but anecdotally seems better for performance
      XRT_COMPOSITOR_FORCE_WAYLAND_DIRECT = "1"; # Fixes wayland

      # Be sure that VRR / Adaptive sync is turned off on your monitor, otherwise you get screen tear

      # These two fix lagginess: https://lvra.gitlab.io/docs/hardware/
      XRT_COMPOSITOR_USE_PRESENT_WAIT = "1";
      U_PACING_COMP_TIME_FRACTION_PERCENT = "90";

      # Recommended by @sapphire from LVRA discord: Uncaps the frame limiter.
      U_PACING_APP_IMMEDIATE_WAIT_FRAME_RETURN = "1";
    };
    services.wivrn = {
      # enable = pkgs.stdenv.hostPlatform.isx86; # seems to be broken on asahi
      enable = false; # seems to be broken on asahi
      # defaultRuntime = true; # Register as default OpenXR runtime
      openFirewall = true;
      # Run WiVRn as a systemd service on startup
      autoStart = false;
    };
    systemd.user.services.wayvr = {
      description = "WayVR OpenXR overlay";

      wantedBy = [ "monado.service" ]; # start wayvr when monado does
      partOf = [ "monado.service" ]; # restart and stop wayvr when monado does
      requires = [ "monado.service" ]; # start monado when wayvr starts
      after = [ "monado.service" ]; # ordering

      serviceConfig = {
        ExecStart = "${pkgs.wayvr}/bin/wayvr";
        Restart = "on-failure";
        RestartSec = 2;
      };
    };
  };
}
