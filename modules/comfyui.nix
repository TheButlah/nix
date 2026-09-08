{
  pkgs,
  config,
  lib,
  username,
  inputs,
  ...
}:
let
  modname = "comfyui";
  cfg = config.thebutlah."${modname}";

  inherit (lib)
    mkIf
    mkEnableOption
    mkOption
    ;
in
{

  imports = [
    # inputs.comfyui-nix.nixosModules.default
    "${inputs.comfyui-nix}/nix/modules/comfyui.nix"
  ];

  options.thebutlah.${modname} = {
    enable = mkEnableOption modname;
  };

  config = mkIf cfg.enable {
    services.comfyui = {
      enable = true;
      gpuSupport = "cuda"; # Enable NVIDIA GPU acceleration (recommended for most users)
      # gpuSupport = "rocm";  # Enable AMD GPU acceleration
      # cudaCapabilities = [ "8.9" ];  # Optional: optimize system CUDA packages for RTX 40xx
      #   Note: Pre-built PyTorch wheels already include every supported GPU architecture
      enableManager = true; # Enable the built-in ComfyUI Manager
      port = 8188;
      listenAddress = "100.94.243.29"; # Use "0.0.0.0" for network access
      dataDir = "/var/lib/comfyui";
      openFirewall = false;
      # extraArgs = [ "--lowvram" ];
      # environment = { };
    };
  };
}
