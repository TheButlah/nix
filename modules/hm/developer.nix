{
  pkgs,
  config,
  lib,
  username,
  ...
}:
let
  modname = "developer";
  # Shorter name to access final settings a
  # user of hello.nix module HAS ACTUALLY SET.
  # cfg is a typical convention.
  cfg = config.thebutlah."${modname}";

  inherit (pkgs.stdenv) isDarwin;
  inherit (pkgs.stdenv) isLinux;
  homeDirectory = if isDarwin then "/Users/${username}" else "/home/${username}";

  inherit (lib)
    mkIf
    mkEnableOption
    mkDefault
    mkOption
    ;

  mkDisableOption =
    name:
    mkOption {
      type = lib.types.bool;
      example = true;
      default = true;
      description = "Whether to enable ${name}.";
    };
in
{
  options.thebutlah.${modname} = {
    enable = mkEnableOption "development tools";
    ai = mkDisableOption "AI tooling";
    android = mkDisableOption "Android Tooling";
    cs = mkDisableOption "C#";
    devops = mkDisableOption "DevOps";
    go = mkDisableOption "Golang";
    js = mkDisableOption "Javascript/Typescript";
    rust = mkDisableOption "Rust";
  };

  config = mkIf cfg.enable {
    home = {
      packages =
        with pkgs;
        [
          cmake
          zig
          gnumake
          ninja
          libiconv # see https://stackoverflow.com/a/69732679

          python312

          just

          gh

          picocom
          probe-rs-tools
        ]
        ++ lib.optionals cfg.go [
          go
        ]
        ++ lib.optionals cfg.android [
          android-tools
        ]
        ++ lib.optionals cfg.devops [
          awscli2
          cloudflare-warp
          cloudflared
          ngrok
          opentofu
          ssm-session-manager-plugin
        ]
        ++ lib.optionals cfg.ai [
          # AI
          unstable.claude-code
          unstable.codex
          unstable.mods
          unstable.ollama
          unstable.openai-whisper
          unstable.ramalama
          unstable.whisper-cpp
        ]
        ++ lib.optionals cfg.rust [
          # Build tools
          cargo-binutils
          cargo-expand
          rustup
          unstable.cargo-zigbuild
        ]
        ++ lib.optionals cfg.js [
          fnm
          bun
        ];
    };

    xdg.enable = true;
    xdg.configFile = mkIf cfg.ai {
      "mods/mods.yml" = {
        source = ../../xdg/mods.yml;
      };
    };

    # shell stuff
    programs.zsh = {
      initContent =
        (lib.optionalString cfg.js ''
          eval "$(fnm env --use-on-cd --shell zsh)"
          export BUN_INSTALL="$HOME/.bun"
          export PATH="$BUN_INSTALL/bin:$PATH"
        '')
        + (lib.optionalString cfg.cs ''
          export PATH="$PATH:${homeDirectory}/.dotnet/tools"
        '');
    };

    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    home.stateVersion = "24.11";
  };

}
