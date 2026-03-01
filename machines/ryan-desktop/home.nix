{
  pkgs,
  config,
  lib,
  username,
  hostname,
  ...
}:
{

  imports = [
    ../../home-common.nix
  ];

  programs.git.settings.user = {
    name = "Ryan Butler";
    email = "thebutlah" + "@" + "gmail.com";
  };

  thebutlah = {
    _1password.enable = true;
    developer.enable = true;
    monado = {
      enable = true;
      xrizer = true;
    };
    music.enable = true;
    social.enable = true;
    terminal = {
      enable = true;
      nvim = true;
    };
    wayland.enable = true;
  };

  programs.ssh.matchBlocks =
    let
      defaults = isTrusted: {
        forwardAgent = isTrusted;
        forwardX11 = true;
        forwardX11Trusted = isTrusted;
      };
      defaultSsh = pkgs.writeText "default.pub" "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJIkanzFkEBan4Qa2bw/2IjEsJaxKo8XbbxwxOBIECEX ryan@1password";
      linodeSsh = pkgs.writeText "linode.pub" "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAFs2eYQL0EOZUgACuXwEteHUtnm0k1KmOeb8WnTiYw8 root@1password";
    in
    {
      "*" = {
        identityAgent = "~/.1password/agent.sock";
        identityFile = "${defaultSsh}";
        identitiesOnly = true;
      };
      "hug" = defaults true // {
        hostname = "huggable.us";
        user = "ryan";
        port = 22;
      };
      "deck" = defaults true // {
        hostname = "deck";
        user = "deck";
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

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "24.11";
}
