# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

# NixOS-WSL specific options are documented on the NixOS-WSL repository:
# https://github.com/nix-community/NixOS-WSL

{
  username,
  hostname,
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    # include NixOS-WSL modules
    inputs.nixos-wsl.nixosModules.default
  ];

  wsl = {
    enable = true;
    defaultUser = "${username}";
    useWindowsDriver = true;
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  environment.systemPackages = with pkgs; [
    neovim
    git
  ];

  programs.zsh.enable = true;

  networking.hostName = "${hostname}";
  programs.ssh.startAgent = true;

  users.users."${username}" = {
    isNormalUser = true;
    description = "${username}";
    extraGroups = [
      "dialout"
      "docker"
      "networkmanager"
      "plugdev"
      "wheel" # Gives sudo
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBLmHbuCMFpOKYvzMOpTOF+iMX9rrY6Y0naarcbWUV8G ryan@ryan-laptop"
    ];
  };
  users.mutableUsers = false;
  users.defaultUserShell = pkgs.zsh;
  security.sudo.wheelNeedsPassword = false;

  hardware.nvidia-container-toolkit = {
    enable = true;
    suppressNvidiaDriverAssertion = true;
    mount-nvidia-executables = false;
  };
  virtualisation = {
    oci-containers.backend = "docker";
    docker = {
      enable = true;
      autoPrune.enable = true;
      enableOnBoot = true;
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}
