{ inputs, ... }:
final: _prev: {
  nixpkgs-23_11 = import inputs.nixpkgs-23_11 {
    system = final.system;
    config.allowUnfree = true;
  };
}
