{ pkgs, ... }: [
  # bootstrap
  # Service that provides nix caches
  pkgs.cachix
  # Better than bash
  pkgs.zsh
  pkgs.git
  # Used for storing large files in git
  pkgs.git-lfs
  pkgs.curl
  pkgs.wget


  # Shell
  # ZSH package manager
  pkgs.oh-my-zsh
  # Nice autosuggestions
  pkgs.zsh-autosuggestions
  # Makes activating project-specific stuff easy
  pkgs.direnv
  # This is missing on mac m1 nix, for some reason. You need it to compile.
  # awesome prompt
  pkgs.starship


  # GUI
  # ~blazingly fast~ terminal in wgpu
  pkgs.wezterm
  (pkgs.nerdfonts.override { fonts = [ "Meslo" "RobotoMono" ]; })


  # CLI
  # best editor
  pkgs.neovim
  # Useful for json manipulation
  pkgs.jq
  # Better than tmux, also rust
  pkgs.zellij
  # Speedy grep replacement
  pkgs.ripgrep
  pkgs.bat
  pkgs.exa
  pkgs.htop


  # Build tools
  # rustToolchain
  pkgs.rustup
  pkgs.cargo-zigbuild
  pkgs.cargo-expand
  pkgs.probe-rs
  pkgs.cargo-binutils
  pkgs.zig
  # If I need to do soy development, at least it wont be with shit tools
  pkgs.fnm
  # see https://stackoverflow.com/a/69732679
  pkgs.libiconv

  # Devops
  pkgs.docker
  pkgs.awscli
]
