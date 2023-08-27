{ pkgs, lib, ... }: {
  home = {
    username = "ryan";
    homeDirectory = "/home/ryan";
    packages = import ./packages/all.nix { inherit pkgs; };
    sessionVariables = { };
  };

  # Enable home-manager and git
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

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.05";
}
