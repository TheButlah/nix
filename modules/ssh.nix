{
  pkgs,
  config,
  lib,
  username,
  ...
}:
let
  modname = "ssh";
  cfg = config.thebutlah."${modname}";

  inherit (lib)
    mkIf
    mkEnableOption
    ;
in
{
  options.thebutlah.${modname} = {
    enable = mkEnableOption modname;
  };

  config = mkIf cfg.enable {
    # Remote connectivity
    services.openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
      settings.PermitRootLogin = "no";
    };
    users.users.${username}.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJIkanzFkEBan4Qa2bw/2IjEsJaxKo8XbbxwxOBIECEX ryan@1password"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG4iOhSHkWTJEOnzyZ+Ny79W47E6UWuHZdJQJUFLrWwL droid@debian"
    ];
  };
}
