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

  programs.ssh.settings =
    let
      defaultSsh = ../../ssh-keys/1password.pub;
      wrSsh = ../../ssh-keys/wr.pub;
    in
    {
      "*" = {
        IdentityAgent = "~/.1password/agent.sock";
        IdentityFile = "${defaultSsh}";
        IdentitiesOnly = true;
      };
      "wr-gh" = {
        HostName = "github.com";
        User = "git";
        IdentityFile = "${wrSsh}";
      };
      "gh" = {
        Hostname = "github.com";
        User = "git";
        IdentityFile = "${defaultSsh}";
      };
    };
}
