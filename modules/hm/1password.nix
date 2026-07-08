{
  pkgs,
  config,
  lib,
  username,
  ...
}:
let
  modname = "_1password";
  # Shorter name to access final settings a
  # user of hello.nix module HAS ACTUALLY SET.
  # cfg is a typical convention.
  cfg = config.thebutlah."${modname}";

  inherit (lib)
    mkIf
    mkEnableOption
    ;

  op = rec {
    acct = {
      me = "PJ5RFQLTJNBQDI3OMBJHR3LOZ4";
    };
    openaiApiKey = {
      acct = acct.me;
      url = "op://Terminal Secrets/OpenAI API Key/credential";
    };
    anthropicApiKey = {
      acct = acct.me;
      url = "op://Terminal Secrets/Anthropic API Key/credential";
    };
    groqApiKey = {
      acct = acct.me;
      url = "op://Terminal Secrets/GROQ_API_KEY/credential";
    };
  };
in
{
  options.thebutlah.${modname} = {
    enable = mkEnableOption "1password";
    isWork = mkEnableOption "work account";
  };

  config = mkIf cfg.enable {
    xdg.enable = true;
    xdg.configFile = {
      "1Password/ssh/agent.toml" = {
        source = ../../xdg/1pass-ssh.toml;
      };
    };

    programs.zsh = {
      initContent = ''
        export OPENAI_API_KEY="''${OPENAI_API_KEY:-"$(op read --account "${op.openaiApiKey.acct}" "${op.openaiApiKey.url}")"}"
        export ANTHROPIC_API_KEY="''${ANTHROPIC_API_KEY:-"$(op read --account "${op.anthropicApiKey.acct}" "${op.anthropicApiKey.url}")"}"
        export GROQ_API_KEY="''${GROQ_API_KEY:-"$(op read --account "${op.groqApiKey.acct}" "${op.groqApiKey.url}")"}"
      '';
    };
  };
}
