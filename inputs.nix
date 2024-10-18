# Maps to the appropriate flake inputs based on the `system`.
{ inputs-raw, system }:
let
  isDarwin = (system == "aarch64-darwin" || system == "x86_64-darwin");
in
{
  self = inputs-raw.self;
  nixpkgs = if isDarwin then inputs-raw.nixpkgs-24_05-darwin else inputs-raw.nixos-24_05;
  nixpkgs-23_11 = if isDarwin then inputs-raw.nixpkgs-23_11-darwin else inputs-raw.nixos-23_11;
  nixpkgs-unstable = if isDarwin then inputs-raw.nixpkgs-unstable else inputs-raw.nixos-unstable;
  nixgl = inputs-raw.nixgl;
  nix-darwin = inputs-raw.nix-darwin;
  flake-utils = inputs-raw.flake-utils;
  fenix = if isDarwin then inputs-raw.fenix-darwin else inputs-raw.fenix-linux;
  home-manager = if isDarwin then inputs-raw.home-manager-darwin else inputs-raw.home-manager-linux;
  nixos-generators = inputs-raw.nixos-generators;
}
