# Common nixos settings shared across machines
{ pkgs, lib, hostname, isWayland ? false, username ? "ryan", isWork ? true, ... }:
let
  pythonShell = (ps: with ps; [
    # add here
  ]);
in
{

  nix = {
    package = pkgs.nix;
    settings = {
      "experimental-features" = [ "nix-command" "flakes" "repl-flake" ];
      "max-jobs" = "auto";
      trusted-users = [
        "root"
        "@wheel"
        username
      ];
    };
  };
  nixpkgs.config.allowUnfree = true;

  users.groups = {
    plugdev = { };
  };
  users.users."${username}" = {
    isNormalUser = true;
    description = "Ryan Butler";
    extraGroups = [
      "networkmanager"
      "wheel"
      "plugdev"
      "dialout"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBLmHbuCMFpOKYvzMOpTOF+iMX9rrY6Y0naarcbWUV8G ryan@ryan-laptop.local"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEoVo3BKge5tQuYpDuWKJaypdpfUuw4cq3/BYRFNovtj ryan.butler@Ryan-Butler.local"
    ];

    shell = pkgs.zsh;
    packages = with pkgs; [
      firefox
      (python3.withPackages pythonShell)
    ];
  };
  users.mutableUsers = false;
  security.sudo.wheelNeedsPassword = false;

  programs.zsh.enable = true;
  programs.nix-ld.enable = true;

  environment.systemPackages = with pkgs; [
    neovim
    vim
    zellij
    (python3.withPackages pythonShell)
  ];

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    passwordAuthentication = false;
  };

  # USB stuff
  services.udev = {
    enable = true;
    extraRules = ''
      SUBSYSTEM=="usb", MODE="0660", GROUP="plugdev"
    '';
  };

  services.resolved = {
    enable = true;
    # set to "false" if giving you trouble 
    dnsovertls = "opportunistic";
  };

  # use the latest Linux kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;
  # Needed for https://github.com/NixOS/nixpkgs/issues/58959
  boot.supportedFilesystems = lib.mkForce [ "btrfs" "reiserfs" "vfat" "f2fs" "xfs" "ntfs" "cifs" ];

  # Enable networking
  networking.networkmanager.enable = true;
  networking.wireless.enable = false;
  networking.hostName = hostname;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11";
}
