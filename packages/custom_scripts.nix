{ pkgs }:
let
  # see https://ertt.ca/nix/shell-scripts/
  fromFile = name: path: (pkgs.writeScriptBin name (builtins.readFile path));
  fromStr = name: str: (pkgs.writeScriptBin name ("#!/bin/sh \n" + str + " $@"));
in
[
  (fromStr "tsh17" "${pkgs.teleport_17}/bin/tsh")
  (fromFile "tid" ../scripts/tid.sh)
]
