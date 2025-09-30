# Maps to the appropriate flake inputs based on the `system`.
{ inputs-raw, system }:
let
  isDarwin = (system == "aarch64-darwin" || system == "x86_64-darwin");
in
{
  self = inputs-raw.self;
  nixpkgs = if isDarwin then inputs-raw.nixpkgs-25_05-darwin else inputs-raw.nixos-25_05;
  nixpkgs-unstable = if isDarwin then inputs-raw.nixpkgs-unstable else inputs-raw.nixos-unstable;
  nixgl = inputs-raw.nixgl;
  nix-darwin = inputs-raw.nix-darwin;
  nixos-wsl = inputs-raw.nixos-wsl;
  flake-utils = inputs-raw.flake-utils;
  fenix = if isDarwin then inputs-raw.fenix-darwin else inputs-raw.fenix-linux;
  home-manager = if isDarwin then inputs-raw.home-manager-darwin else inputs-raw.home-manager-linux;
  home-manager-unstable = if isDarwin then throw "unstable hm should only be used on asahi" else inputs-raw.home-manager-linux-unstable;
  nixos-generators = inputs-raw.nixos-generators;
  nixos-apple-silicon = inputs-raw.nixos-apple-silicon;
  anyrun = inputs-raw.anyrun;
  inhibitor = inputs-raw.inhibitor;
  niri-flake = inputs-raw.niri-flake;
  swww = inputs-raw.swww;
  xremap-flake = inputs-raw.xremap-flake;
  kolide-launcher = inputs-raw.kolide-launcher;
  disko = inputs-raw.disko;
}
