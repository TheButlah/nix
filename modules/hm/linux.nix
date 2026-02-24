# Linux-only configuration
{
  pkgs,
  lib,
  ...
}:
lib.mkIf pkgs.stdenv.isLinux {
  # Noise suppression etc
  services.easyeffects.enable = true;
}
