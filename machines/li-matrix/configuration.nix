{
  pkgs,
  lib,
  inputs,
  config,
  hostname,
  username,
  modulesPath,
  ...
}:
{

  imports = [
    inputs.disko.nixosModules.disko
    ./disko.nix
    (modulesPath + "/profiles/qemu-guest.nix")
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
  # # programs.ssh.startAgent = true;
  # services.mullvad-vpn.enable = false;
  # services.tailscale.enable = true;

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
    # neovim
    # ripgrep
    # usbutils # lsusb
    # vim
    wget
  ];

  # Enable LISH and Linode Booting w/ GRUB
  boot = {
    # Add Required Kernel Modules
    # NOTE: These are not documented in the install guide
    initrd.availableKernelModules = [
      "ahci"
      "sd_mod"
    ];

    # Set Up LISH Serial Connection
    kernelParams = [ "console=ttyS0,19200n8" ];

    loader = {
      # Increase Timeout to Allow LISH Connection
      # NOTE: The image generator tries to set a timeout of 0, so we must force
      timeout = lib.mkForce 10;

      grub = {
        enable = true;
        forceInstall = true;
        # device = "/dev/sda";

        # Allow serial connection for GRUB to be able to use LISH
        extraConfig = ''
          serial --speed=19200 --unit=0 --word=8 --parity=no --stop=1;
          terminal_input serial;
          terminal_output serial
        '';
      };
    };
  };

  system.stateVersion = "25.05";
}
