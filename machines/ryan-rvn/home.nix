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
    music.enable = true;
    social = {
      enable = false;
      isWork = true;
    };
    terminal = {
      enable = true;
      nvim = true;
    };
    wayland.enable = isLinux;
  };

  programs.ssh.settings =
    let
      defaultSsh = ../../ssh-keys/1password.pub;
      rvnSsh = ../../ssh-keys/raven.pub;
    in
    {
      "*" = {
        IdentityAgent = "~/.1password/agent.sock";
        IdentityFile = "${defaultSsh}";
        IdentitiesOnly = true;
      };
      "rvn-gh" = {
        HostName = "github.com";
        User = "git";
        IdentityFile = "${rvnSsh}";
      };
      "gh" = {
        Hostname = "github.com";
        User = "git";
        IdentityFile = "${defaultSsh}";
      };
      "rvn" = {
        Hostname = "192.168.196.188"; # s1.in.raven.computer
        User = "ryan";
        IdentityFile = "${rvnSsh}";
      };
    };
}
