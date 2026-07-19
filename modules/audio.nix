{
  pkgs,
  config,
  lib,
  username,
  ...
}:
let
  modname = "audio";
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
    environment.systemPackages = with pkgs; [
      qpwgraph # control pipewire nodes using a GUI
      alsa-utils # aplay, arecord, etc
      easyeffects
      pavucontrol # volume control
    ];

    services.pipewire = {
      enable = true; # redundant, here for clarity
      pulse.enable = true; # redundant?
      wireplumber = {
        enable = true; # redundant, here for clarify
        configPackages = [
          # (pkgs.writeTextDir "share/wireplumber/wireplumber.conf.d/10-loopback-pro-audio.conf" (
          #   builtins.readFile ../../xdg/wireplumber-pro-audio.conf
          # ))
        ];
      };
    };
    # redundant, here for clarity. This should be false when using sound servers
    hardware.alsa.enable = false;
  };
}
