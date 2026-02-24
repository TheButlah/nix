{
  pkgs,
  lib,
  inputs,
  config,
  hostname,
  username,
  ...
}:
{

  imports = [
    inputs.disko.nixosModules.disko
    ./disko.nix
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nix.settings.trusted-users = [
    "root"
    "${username}"
  ];

  networking.hostName = hostname;
  networking.useDHCP = lib.mkDefault true;

  # Remote connectivity
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.PermitRootLogin = "no";
  };
  # programs.ssh.startAgent = true;
  services.mullvad-vpn.enable = false;
  services.tailscale.enable = true;

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."${username}" = {
    isNormalUser = true;
    extraGroups = [
      "dialout"
      "docker"
      "libvirt"
      "networkmanager"
      "plugdev"
      "podman"
      "wheel"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAFs2eYQL0EOZUgACuXwEteHUtnm0k1KmOeb8WnTiYw8"
    ];
  };
  users.defaultUserShell = pkgs.zsh;
  users.groups = {
    plugdev = { };
    dialout = { };
  };

  programs = {
    zsh.enable = true;
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    curl
    git
    neovim
    ripgrep
    usbutils # lsusb
    vim
    wget
  ];

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";

  system.stateVersion = "25.05";
}
