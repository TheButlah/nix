# nix-darwin config
{ pkgs, lib, inputs, hostname, username, ... }:
let
  inherit (inputs) self;
in
{
  nix = {
    enable = false; # managed by determinate
    package = pkgs.nix;
    channel.enable = false;
    # nixPath = lib.mkForce [ "nixpkgs=flake:nixpkgs" ];
    settings = {
      "experimental-features" = [ "nix-command" "flakes" ];
      "max-jobs" = "auto";
      trusted-users = [
        "root"
        "@admin"
        username
      ];
    };
    linux-builder = {
      enable = false; # incompatible with determinate
      # Clears builder filesystem on restart, to avoid state accumulation
      ephemeral = true;
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      # NOTE: For some reason we can't set `config` if we want things to work the first
      # try. It seems to be stateful??
      # config = {
      #   virtualisation = {
      #     darwin-builder = {
      #       diskSize = 40 * 1024;
      #       memorySize = 8 * 1024;
      #     };
      #     cores = 6;
      #   };
      # };
    };
  };
  nixpkgs.flake = {
    setFlakeRegistry = false; # incompatible with determinate
    setNixPath = false; # incompatible with determinate
  };
  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
  system.primaryUser = username;

  # Set Git commit hash for darwin-version.
  system.configurationRevision = self.rev or self.dirtyRev or null;

  programs.zsh.enable = true; # default shell on catalina

  environment.systemPackages = [
    pkgs.home-manager
  ];

  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToControl = true;
  };
  networking.hostName = "${hostname}";

  # TODO: For some reason these don't do anything on my work laptop
  system.defaults.NSGlobalDomain = {
    # Use fn keys as regular keys.
    "com.apple.keyboard.fnState" = true;
    AppleInterfaceStyleSwitchesAutomatically = true;
    AppleICUForce24HourTime = true;
    # Whether to enable “Natural” scrolling direction
    "com.apple.swipescrolldirection" = false;
  };
  # default dock animation when autohiding is trash.
  # make it a lot snappier.
  system.defaults.dock = {
    autohide = true;
    autohide-delay = 0.0;
    autohide-time-modifier = 0.2;
  };
  system.defaults.finder.AppleShowAllFiles = true;
  system.defaults.screensaver.askForPassword = true;

  # keyboard customization system for macos.
  # currently we just use it for disabling the builting keeb when corne is
  # connected
  # currently disabled due to bug, we get it from brew instead:
  # https://github.com/nix-darwin/nix-darwin/issues/1041
  services.karabiner-elements.enable = false;

  security.sudo.extraConfig = ''
    Defaults timestamp_timeout=60
  '';

  homebrew = {
    enable = true;
    brews = [ ];
    casks = [
      "karabiner-elements"
      "mullvadvpn"
      "spotify"
      "tailscale"
      "tidal"
    ];
    taps = [ "LizardByte/homebrew" ];
  };
}
