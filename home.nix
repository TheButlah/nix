{ pkgs, lib, ... }: {
  home = {
    username = "ryan";
    homeDirectory = "/home/ryan";
    packages = import ./packages/all.nix { inherit pkgs; };
    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
  };

  programs.home-manager.enable = true;
  programs.git.enable = true;
  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    oh-my-zsh.enable = true;
    defaultKeymap = "vicmd";
  };
  programs.starship = {
    enable = true;
    settings = lib.trivial.importTOML ./starship.toml;
  };

  xdg.enable = true;
  xdg.configFile = {
    "nvim" = {
      source = pkgs.fetchgit {
        url = "https://github.com/thebutlah/init.lua";
        sha256 = "sha256-0Hea7q2OaB6Gld5n5MztxIE4wJapCAjSPD4Cz7+Z044=";
      };
    };
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.05";
}
