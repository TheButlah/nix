{ pkgs
, isWork
, isWayland
, isGui
, ...
}:
with pkgs;
[
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
  # legcord

  # CLI
  asciinema
  b3sum
  bat
  bottom
  dust
  eza
  file
  gh
  glow
  htop
  jq
  neofetch
  neovim
  picocom
  ripgrep
  shellcheck
  tree
  tree-sitter
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
  nixfmt # formats nix files
  probe-rs-tools
  python312
  rustup
  unstable.cargo-zigbuild
  zig

  # Devops
  # _1password-cli # broken
  awscli2
  cloudflared
  gnupg
  ngrok
  ssm-session-manager-plugin
  terraform
  sshfs

  # AI
  unstable.claude-code
  unstable.codex
  unstable.mods
  unstable.ollama
  unstable.openai-whisper
  unstable.whisper-cpp
  unstable.ramalama
]
++ lib.optionals (!isWork) [
  syncthing
  # discord
]
++ lib.optionals (isWork) [
]
++ lib.optionals (pkgs.stdenv.isDarwin) [
]
++ lib.optionals (pkgs.stdenv.isLinux) [
  (if isWayland then wl-clipboard else xclip)
  nixgl.auto.nixGLDefault
]
++ lib.optionals (pkgs.stdenv.isLinux && isWork) [
  cloudflare-warp
]
++ lib.optionals (pkgs.stdenv.isLinux && !isWork && isGui) [
  legcord
  mixxx
]
++ lib.optionals (isGui) [
  wezterm # ~blazingly fast~ terminal in wgpu
  vscodium
]
++ (import ./custom_scripts.nix { pkgs = pkgs; })
