{ pkgs }:
let
  # see https://ertt.ca/nix/shell-scripts/
  script = name: path: (pkgs.writeScriptBin name (builtins.readFile path));
in
[
  (script "tid" ../scripts/tid.sh)
]
