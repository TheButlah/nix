# Linux-only configuration
{ pkgs
, lib
, ...
}:
let
  inherit (pkgs.stdenv) isDarwin;
  inherit (pkgs.stdenv) isLinux;

  # see https://ertt.ca/nix/shell-scripts/
  fromFile = name: path: (pkgs.writeScriptBin name (builtins.readFile path));
  fromStr = name: str: (pkgs.writeScriptBin name ("#!/bin/sh \n" + str + " $@"));
in
lib.mkIf pkgs.stdenv.isLinux {
  # Noise suppression etc
  services.easyeffects.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  home.packages = [
    (fromFile "rmbcm" ../../scripts/rmbcm.sh)
  ];
}
