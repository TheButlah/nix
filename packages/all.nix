{ pkgs, isWork ? true, isWayland ? false, ... }: with pkgs; [
  # bootstrap
  bash # Macos has an old bash
  cachix # Service that provides nix caches
  coreutils # MacOS uses BSD coreutils, use gnu instead
  curl
  git
  git-lfs
  gnutar # Macos has an old/weird tar
  unzip
  wget
  zsh

  # GUI
  # alacritty # handled by home-manager
  (nerdfonts.override { fonts = [ "Meslo" "RobotoMono" ]; })
  wezterm # ~blazingly fast~ terminal in wgpu
  vscodium

  # CLI
  asciinema
  bat
  eza
  file
  gh
  glow
  htop
  jq
  unstable.neovim
  picocom
  ripgrep
  shellcheck
  tree
  unstable.zellij
  watch
  zoxide

  # Build tools
  android-tools
  cargo-binutils
  cargo-expand
  cmake
  fnm # If I need to do soy development, at least it wont be with shit tools
  gnumake
  go
  just
  libiconv # see https://stackoverflow.com/a/69732679
  ninja
  nixpkgs-fmt # formats nix files
  probe-rs
  python312
  rustup
  unstable.cargo-zigbuild
  zig

  # Devops
  awscli2
  cloudflared
  gnupg
  ngrok
  podman
  terraform

  # security
  _1password

  # AI
  unstable.mods
  unstable.ollama
  unstable.openai-whisper
  unstable.openai-whisper-cpp
] ++ lib.optionals (!isWork) [
  # discord
] ++ lib.optionals (pkgs.stdenv.isDarwin) [
] ++ lib.optionals (pkgs.stdenv.isLinux) [
  (if isWayland then wl-clipboard else xclip)
  nixgl.auto.nixGLDefault
] ++ (import ./custom_scripts.nix { pkgs = pkgs; })
