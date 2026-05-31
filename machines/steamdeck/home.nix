{
  pkgs,
  config,
  lib,
  username,
  hostname,
  ...
}:
let
  inherit (pkgs.stdenv) isDarwin;
  inherit (pkgs.stdenv) isLinux;
in
{

  imports = [
    ../../home-common.nix
  ];

  home.packages = with pkgs; [
    # nixgl.nixGLIntel
    # nixgl.nixVulkanIntel
  ];

  programs.git.settings.user = {
    name = "Ryan Butler";
    email = "thebutlah" + "@" + "gmail.com";
  };

  thebutlah = {
    _1password.enable = false;
    developer.enable = true;
    terminal = {
      enable = true;
      nvim = true;
    };
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "24.11";
}
