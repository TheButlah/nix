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
    ../modules/hm/common.nix
  ];

  thebutlah.terminal.enable = true;
  thebutlah.developer.enable = true;

  programs.ssh.matchBlocks =
    let
      defaults = isTrusted: {
        forwardAgent = isTrusted;
        forwardX11 = true;
        forwardX11Trusted = isTrusted;
      };
      defaultSsh = ../ssh-keys/1password.pub;
      rvSsh = ../ssh-keys/raven.pub;
      wrSsh = ../ssh-keys/wr.pub;
      linodeSsh = ../ssh-keys/linode.pub;
    in
    {
      "*" = {
        identityFile = "${defaultSsh}";
        identitiesOnly = true;
      };
      "rv-gh" = {
        hostname = "github.com";
        user = "git";
        identityFile = "${rvSsh}";
      };
      "wr-gh" = {
        hostname = "github.com";
        user = "git";
        identityFile = "${wrSsh}";
      };
      "gh" = {
        hostname = "github.com";
        user = "git";
        identityFile = "${defaultSsh}";
      };
    };
}
