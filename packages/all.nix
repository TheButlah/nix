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
  # legcord

  # CLI
  asciinema
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
  picocom
  ripgrep
  shellcheck
  tree
  unstable.neovim
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
  # _1password-cli # broken
  awscli2
  cloudflared
  gnupg
  ngrok
  ssm-session-manager-plugin
  terraform

  # AI
  unstable.claude-code
  unstable.codex
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
