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
      tfh = "72J3ELVKX5BTPKT44JPHXUD6AM";
      me = "PJ5RFQLTJNBQDI3OMBJHR3LOZ4";
    };
    openaiApiKey =
      if cfg.isWork then
        {
          acct = acct.tfh;
          url = "op://Engineering/Orb SW OpenAI API Key/credential";
        }
      else
        {
          acct = acct.me;
          url = "op://Terminal Secrets/OpenAI API Key/credential";
        };
    anthropicApiKey =
      if cfg.isWork then
        {
          acct = acct.tfh;
          url = "op://Engineering/Orb SW Anthropic API Key/credential";
        }
      else
        {
          acct = acct.me;
          url = "op://Terminal Secrets/Anthropic API Key/credential";
        };
    groqApiKey =
      if cfg.isWork then
        {
          acct = acct.tfh;
          url = "op://Employee/GROQ_API_KEY/credential";
        }
      else
        {
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

    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    home.stateVersion = "24.11";
  };

}
