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

  # see https://ertt.ca/nix/shell-scripts/
  fromFile = name: path: (pkgs.writeScriptBin name (builtins.readFile path));
  fromStr = name: str: (pkgs.writeScriptBin name ("#!/bin/sh \n" + str + " $@"));
in
{

  imports = [
    ../../home-common.nix
  ];

  home.packages = [
    (fromStr "tsh17" "${pkgs.teleport_17}/bin/tsh")
    (fromFile "tid" ../../scripts/tid.sh)

    nixgl.nixGLIntel
    nixgl.nixVulkanIntel
  ];

  programs.git.settings.user = {
    name = "Ryan Butler";
    email = "thebutlah" + "@" + "gmail.com";
  };

  thebutlah = {
    _1password.enable = true;
    developer.enable = true;
    music.enable = true;
    social.enable = true;
    terminal = {
      enable = true;
      nvim = true;
    };
    wayland.enable = isLinux;
  };

  programs.ssh.matchBlocks =
    let
      defaults = isTrusted: {
        forwardAgent = isTrusted;
        forwardX11 = true;
        forwardX11Trusted = isTrusted;
      };
      defaultSsh = pkgs.writeText "default.pub" "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJIkanzFkEBan4Qa2bw/2IjEsJaxKo8XbbxwxOBIECEX ryan@1password";
    in
    {
      "*" = {
        identityAgent = "~/.1password/agent.sock";
        identityFile = "${defaultSsh}";
        identitiesOnly = true;
      };
      "hil" = defaults true // {
        hostname = "ryan-worldcoin-hil.tail189ef.ts.net";
        user = "worldcoin";
      };
      "i-* mi-*" = defaults true // {
        proxyCommand = "sh -c \"aws ssm start-session --target %h --document-name AWS-StartSSHSession --parameters 'portNumber=%p'\"";
      };
    };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "24.11";
}
