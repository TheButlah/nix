# Common configuration.nix functionality. most stuff is broken into modules
{
  pkgs,
  config,
  lib,
  username,
  hostname,
  isWork,
  ...
}:
let
  inherit (pkgs.stdenv) isDarwin;
  inherit (pkgs.stdenv) isLinux;
in
{

  imports = [
    ./monado.nix
  ];

}
