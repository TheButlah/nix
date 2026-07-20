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
    ./bluetooth.nix
    ./devices.nix
    ./display-manager.nix
    ./inhibitor.nix
    ./monado.nix
    ./nix-ld.nix
    ./selfhosting.nix
    ./ssh.nix
    ./streaming.nix
    ./systemd-boot.nix
    ./virtualization.nix
    ./vpn.nix
    ./xremap.nix
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
      "networkmanager"
      "syncthing"
      "wheel"
    ];
  };
  users.defaultUserShell = pkgs.zsh;
  programs.zsh.enable = true;

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  fonts.packages = with pkgs; [
    nerd-fonts.meslo-lg
    nerd-fonts.roboto-mono
  ];

  services.flatpak.enable = true;
}
