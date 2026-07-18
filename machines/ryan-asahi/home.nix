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
    ../../modules/hm/common.nix
  ];

  home.packages = with pkgs; [
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
    monado = {
      enable = isLinux;
      opencomposite = true;
      # xrizer = true; # currently broken
    };
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
      defaultSsh = ../../ssh-keys/1password.pub;
      rvSsh = ../../ssh-keys/raven.pub;
      wrSsh = ../../ssh-keys/wr.pub;
      linodeSsh = ../../ssh-keys/linode.pub;
    in
    {
      "*" = {
        identityAgent = "~/.1password/agent.sock";
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
      "rvn" = defaults true // {
        hostname = "192.168.196.188";
        user = "ryan";
        identityFile = "${rvSsh}";
      };
      "hug" = defaults true // {
        hostname = "huggable.us";
        user = "ryan";
        port = 22;
      };
      "deck" = defaults true // {
        hostname = "192.168.0.12";
        user = "deck";
        identityFile = "${defaultSsh}";
      };
      "desk" = defaults true // {
        hostname = "ryan-desktop.stalk-corn.ts.net";
        user = "ryan";
      };
      "li-matrix" = defaults true // {
        hostname = "matrix.thebutlah.com";
        user = "root";
        identityFile = "${linodeSsh}";
      };
      "i-* mi-*" = defaults true // {
        proxyCommand = "sh -c \"aws ssm start-session --target %h --document-name AWS-StartSSHSession --parameters 'portNumber=%p'\"";
      };
    };
}
