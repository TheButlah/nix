{ pkgs, lib, config, username, ... }: {
  home = {
    inherit username;
    homeDirectory = "/home/${username}";
    packages = import ./packages/all.nix { inherit pkgs; };
    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
  };

  programs.home-manager.enable = true;
  programs.git = {
    enable = true;
    userName = "Ryan Butler";
    userEmail = "thebutlah" + /* This is done to avoid spam */ "@gmail.com";
    lfs.enable = true;
  };
  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    oh-my-zsh.enable = true;
    initExtra = ''
      		set -o vi
      	'';
  };
  programs.starship = {
    enable = true;
    settings = lib.trivial.importTOML ./starship.toml;
  };
  programs.wezterm = {
    enable = true;
    extraConfig = builtins.readFile ./wezterm.lua;
  };
  programs.zellij = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
  };
  programs.direnv.enable = true;

  xdg.enable = true;
  xdg.configFile = {
    # TODO: Try to get this to work
	# See https://www.reddit.com/r/neovim/comments/15lvm44/treesitter_through_nixhomemanager_all_other/jvflvyq/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button
	# Raw symlink to the plugin manager lock file, so that it stays writeable
    # "nvim/lazy-lock.json".source = config.lib.file.mkOutOfStoreSymlink "${nvim_cfg}/lazy-lock.json";
    # "nvim" = {
    #   source = nvim_cfg;
    # };
  };

  fonts.fontconfig.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.05";
}
