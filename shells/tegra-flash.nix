# source this with nix-shell ~/P/nix/shells/tegra-flash.nix
# provides the necessary dependencies for flashing.
{ pkgs ? import <nixpkgs> { } }:
let
  pythonShell = (ps: with ps; [
    pyyaml
    pyserial # just for convenience
    pyftdi # for controlling UART adapter

    # for jtag debugger
    pyocd
    cmsis-pack-manager
    cffi
  ]);
in
(pkgs.buildFHSEnv {
  name = "tegra-env";
  targetPkgs = pkgs: (with pkgs; [
    (python3.withPackages pythonShell)
    lz4
    perl
    udev
  ]);
  runScript = "bash";
}).env 
