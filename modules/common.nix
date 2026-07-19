# Common configuration.nix functionality. most stuff is broken into modules
{
  pkgs,
  config,
  username,
  hostname,
  self,
  ...
}:
let
  inherit (pkgs.stdenv) isDarwin;
  inherit (pkgs.stdenv) isLinux;
in
{

  imports = [
    ./audio.nix
    ./monado.nix
    ./selfhosting.nix
    ./ssh.nix
    ./virtualization.nix
    ./vpn.nix
  ];

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    trusted-users = [
      "root"
      "${username}"
    ];
    auto-optimise-store = true;
    extra-platforms = config.boot.binfmt.emulatedSystems;
  };

  # make the original flake present for inspection
  environment.etc."nixos".source = self.outPath;

  networking.hostName = hostname;

  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [
      "adbusers"
      "dialout"
      "networkmanager"
      "plugdev"
      "syncthing"
      "wheel"
      "yubihsm"
    ];
  };
  users.defaultUserShell = pkgs.zsh;
  users.groups = {
    plugdev = { };
    dialout = { };
    yubihsm = { };
  };
  programs.zsh.enable = true;

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  fonts.packages = with pkgs; [
    nerd-fonts.meslo-lg
    nerd-fonts.roboto-mono
  ];

  networking.firewall.trustedInterfaces = [
    "nxpeth0"
  ];

  # USB stuff
  services.udev = {
    enable = true;
    packages = with pkgs; [
      yubikey-personalization # needed for yubikey-manager
    ];
    extraRules = ''
      # USB mass storage devices
      SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ENV{ID_USB_INTERFACES}=="*:08????:*", MODE="0660", GROUP="plugdev"
      SUBSYSTEM=="block", SUBSYSTEMS=="usb", MODE="0660", GROUP="plugdev"

      # USB HID devices
      SUBSYSTEM=="hidraw", SUBSYSTEMS=="usb", MODE="0660", GROUP="plugdev"

      # SYMLINK also creates a .device with the path of the symlink, i.e. `dev-corne.device`
      ACTION=="add", KERNEL=="event*", SUBSYSTEM=="input", ATTRS{id/vendor}=="1d50", ATTRS{id/product}=="615e", ATTRS{name}=="Corne Keyboard", SYMLINK+="corne", TAG+="systemd", ENV{SYSTEMD_WANTS}="wireless-keyboard.target"

      # IMX usb ethernet
      ACTION=="add", SUBSYSTEM=="net", SUBSYSTEMS=="usb", ATTRS{idVendor}=="0525", ATTRS{idProduct}=="a4a2", NAME="nxpeth%n"

      # yubihsm
      SUBSYSTEM=="usb", ATTR{idVendor}=="1050", ATTR{idProduct}=="0030", MODE="0660", GROUP="yubihsm"

      # Bigscreen Beyond
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="35bd", ATTRS{idProduct}=="0101", MODE="0660", GROUP="users"
      # Bigscreen Bigeye
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="35bd", ATTRS{idProduct}=="0202", MODE="0660", GROUP="users"
      # Bigscreen Beyond Audio Strap
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="35bd", ATTRS{idProduct}=="0105", MODE="0660", GROUP="users"
      # Bigscreen Beyond Firmware Mode?
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="35bd", ATTRS{idProduct}=="4004", MODE="0660", GROUP="users"
    '';
  };
}
