# nix-darwin config
{ pkgs, lib, inputs, ... }:
let
  inherit (inputs) self;
in
{
  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  nix = {
    package = pkgs.nix;
    settings = {
      "experimental-features" = [ "nix-command" "flakes" "repl-flake" ];
      "max-jobs" = "auto";
    };
  };
  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

  # Set Git commit hash for darwin-version.
  system.configurationRevision = self.rev or self.dirtyRev or null;

  programs.zsh.enable = true; # default shell on catalina

  environment.systemPackages = [
    pkgs.home-manager
  ];
}
