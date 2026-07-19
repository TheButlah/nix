{
  pkgs,
  config,
  lib,
  username,
  ...
}:
let
  modname = "nix-ld";
  cfg = config.thebutlah."${modname}";

  inherit (lib)
    mkIf
    mkEnableOption
    mkOption
    ;
  mkDisableOption =
    name:
    mkOption {
      type = lib.types.bool;
      example = true;
      default = true;
      description = "Whether to enable ${name}.";
    };

  system = pkgs.stdenv.hostPlatform.system;
  crossVars =
    let
      mkCrossVars = pkgsCross: rec {
        dynamicLinker = pkgsCross.stdenv.cc.bintools.dynamicLinker;
        ldsoDir = pkgsCross.stdenv.hostPlatform.libDir;
        ldsoName = builtins.baseNameOf dynamicLinker;
        crossSystem = pkgsCross.stdenv.hostPlatform.system;
        inherit pkgsCross;
      };
      aarch64PkgsCross = pkgs.pkgsCross.aarch64-multiplatform;
      x86PkgsCross = pkgs.pkgsCross.gnu64;
      pkgsCross = if system == "x86_64-linux" then aarch64PkgsCross else x86PkgsCross;
    in
    mkCrossVars pkgsCross;
in
{
  options.thebutlah.${modname} = {
    enable = mkDisableOption modname;
  };

  config = mkIf cfg.enable {
    thebutlah.virtualization.enable = true;

    # Set up nix-ld as well as nix-ld for emulated aarch64.
    programs.nix-ld.enable = true;

    environment.sessionVariables = {
      "NIX_LD_${crossVars.crossSystem}" = crossVars.dynamicLinker;
    };
    systemd.tmpfiles.rules = [
      "d /${crossVars.ldsoDir} 0755 root root - -"
      "L+ /${crossVars.ldsoDir}/${crossVars.ldsoName} - - - - ${crossVars.pkgsCross.nix-ld}/libexec/nix-ld"
    ];
  };
}
