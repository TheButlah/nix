{
  config,
  pkgs,
  lib,
  ...
}:
let
  username = "ryan";
  hostname = "us-east-linode-1";
in
{
  networking.hostName = "${hostname}";

  environment.systemPackages = with pkgs; [
    curl
    git
    neovim
    parted
    usbutils
    vim
  ];

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
    };
  };

  # Enable networking
  # networking.networkmanager.enable = true;

  users.users."${username}" = {
    isNormalUser = true;
    description = "${username}";
    extraGroups = [
      "networkmanager"
      "wheel" # Gives sudo
      "plugdev"
      "dialout"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBLmHbuCMFpOKYvzMOpTOF+iMX9rrY6Y0naarcbWUV8G ryan@ryan-laptop"
    ];
  };
  users.mutableUsers = false;
  security.sudo.wheelNeedsPassword = false;

  programs.zsh.enable = true;
  programs.nix-ld.enable = true;

  # use the latest Linux kernel
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    # Needed for https://github.com/NixOS/nixpkgs/issues/58959
    supportedFilesystems = lib.mkForce [
      "btrfs"
      "reiserfs"
      "vfat"
      "f2fs"
      "xfs"
      "ntfs"
      "cifs"
    ];
  };

  system.stateVersion = "24.05";
}
