# Common nixos settings shared across machines
{ pkgs, lib, isWayland ? false, username ? "ryan", isWork ? true, ... }:
let
  pythonShell = (ps: with ps; [
    # add here
  ]);
in
{

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
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
    shell = pkgs.zsh;
    packages = with pkgs; [
      firefox
      (python3.withPackages pythonShell)
    ];
  };

  programs.zsh.enable = true;
  programs.nix-ld.enable = true;

  environment.systemPackages = with pkgs; [
    neovim
    vim
    zellij
    (python3.withPackages pythonShell)
  ];

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # USB stuff
  services.udev = {
    enable = true;
    extraRules = ''
      SUBSYSTEM=="usb", MODE="0660", GROUP="plugdev"
    '';
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11";

}
