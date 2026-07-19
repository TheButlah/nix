{
  pkgs,
  config,
  lib,
  username,
  ...
}:
let
  modname = "virtualization";
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
    hardware.nvidia-container-toolkit = {
      enable = config.hardware.nvidia.enabled;
      # suppressNvidiaDriverAssertion = true;
    };

    environment.systemPackages = with pkgs; [
      virt-manager # for virt-install
    ];

    virtualisation = {
      containers.enable = true;
      oci-containers.backend = "podman";
      podman = {
        enable = true;
        # docker` alias for podman
        dockerCompat = false;
        # Required for containers under podman-compose to be able to talk to each other.
        defaultNetwork.settings.dns_enabled = true;
      };
      docker = {
        daemon.settings.features.cdi = true;
        enable = true;
        autoPrune.enable = true;
        enableOnBoot = true;
      };
      libvirtd.enable = true;
    };

    users.users.${username}.extraGroups = [
      "docker"
      "podman"
      "libvirt"
    ];
  };
}
