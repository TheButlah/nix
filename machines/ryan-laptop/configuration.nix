# nix-darwin config
{ pkgs, lib, inputs, ... }: {
  environment.systemPackages = [
    pkgs.home-manager
  ];
  
  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  nix = {
    package = pkgs.nix;
    settings = {
      "experimental-features" = [ "nix-command" "flakes" "repl-flake" ];
	  "max-jobs" = "auto";
    };
  };
  nixpkgs.hostPlatform = "aarch64-darwin"; 
}
