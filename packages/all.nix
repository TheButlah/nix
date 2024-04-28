{ pkgs, isWork ? true, isWayland ? false, ... }: with pkgs; [
  # bootstrap
  # Service that provides nix caches
  cachix
  zsh
  # Macos has an old bash
  bash
  git
  # Used for storing large files in git
  git-lfs
  curl
  wget
  # Macos has an old/weird tar
  gnutar
  # Some distros don't have unzip
  unzip
  # MacOS uses BSD coreutils, this improves compatibility
  coreutils

  # Shell
  # ZSH package manager
  oh-my-zsh
  # Nice autosuggestions
  zsh-autosuggestions
  # Makes activating project-specific stuff easy
  direnv
  # This is missing on mac m1 nix, for some reason. You need it to compile.
  # awesome prompt
  starship

  # GUI
  # ~blazingly fast~ terminal in wgpu
  wezterm
  # alacritty # handled by home-manager
  (nerdfonts.override { fonts = [ "Meslo" "RobotoMono" ]; })

  # CLI
  # best editor
  neovim
  # Useful for json manipulation
  jq
  # Better than tmux, also rust
  zellij
  # Speedy grep replacement
  ripgrep
  asciinema
  bat
  eza
  gh
  glow
  htop
  mods
  picocom
  shellcheck
  tree
  watch
  zoxide

  # Build tools
  # rustToolchain
  rustup
  cargo-zigbuild
  cargo-expand
  probe-rs
  cargo-binutils
  zig
  # If I need to do soy development, at least it wont be with shit tools
  fnm
  # see https://stackoverflow.com/a/69732679
  libiconv
  python312
  go
  android-tools
  cmake
  ninja
  gnumake

  # Devops
  docker
  awscli
  gnupg

  # security
  _1password
] ++ lib.optionals (!isWork) [
  # discord
] ++ lib.optionals (pkgs.stdenv.isDarwin) [
] ++ lib.optionals (pkgs.stdenv.isLinux) [
  (if isWayland then wl-clipboard else pkgs.xclip)
  nixgl.auto.nixGLDefault
]
