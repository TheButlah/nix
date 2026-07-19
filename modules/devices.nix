{
  pkgs,
  config,
  lib,
  username,
  ...
}:
let
  modname = "devices";
  cfg = config.thebutlah."${modname}";

  inherit (lib)
    mkIf
    mkMerge
    mkEnableOption
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
    enable = mkDisableOption modname;
    usbguard = mkEnableOption "usbguard";

    at2020 = mkDisableOption "AT2020+";
    bigscreen = mkDisableOption "Bigscreen Beyond";
    corne = mkDisableOption "Corne Keyboard";
    dac = mkDisableOption "Digital Audio Converters";
    elektron = mkDisableOption "Elektron";
    ftdi = mkDisableOption "FTDI";
    jetson = mkDisableOption "NVIDIA Jetson";
    nxpimx = mkDisableOption "NXP IMX chips";
    pixel10 = mkDisableOption "Pixel 10";
    yubico = mkDisableOption "Yubikey and Yubihsm";
  };

  config = mkIf cfg.enable (mkMerge [
    # common
    {
      users.groups = {
        plugdev = { };
        dialout = { };
      };
      users.users.${username}.extraGroups = [
        "plugdev"
        "dialout"
      ];

      services.udev = {
        enable = true;
        extraRules = ''
          # USB mass storage devices
          SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ENV{ID_USB_INTERFACES}=="*:08????:*", MODE="0660", GROUP="plugdev"
          SUBSYSTEM=="block", SUBSYSTEMS=="usb", MODE="0660", GROUP="plugdev"

          # USB HID devices
          SUBSYSTEM=="hidraw", SUBSYSTEMS=="usb", MODE="0660", GROUP="plugdev"
        '';
      };
      services.usbguard = {
        enable = cfg.usbguard;
        rules = ''
          # Generic classes
          allow with-interface equals { 09:00:* } # usb hubs
          allow with-interface equals { 09:00:* 09:00:* } # usb hubs w multiple protocols
          allow with-interface equals { 08:*:* } # Mass storage
          allow with-interface equals { 08:*:* 08:*:* } # Mass storage with multiple protocols
          allow with-interface equals { 01:*:* } # Audio
          allow with-interface equals { 11:*:* } # Billboard devices

          # Specific Devices
        '';
        implicitPolicyTarget = "block";
        presentDevicePolicy = "apply-policy";
        presentControllerPolicy = "keep";
        insertedDevicePolicy = "apply-policy";
      };
    }

    (mkIf cfg.at2020 {
      services.usbguard.rules = ''
        allow id 0909:001c serial "" name "AT2020USB+" hash "/Rj52epXXbngHHurEDmdeKQOn/F9aYSO4ChFo/Snpgo=" with-interface { 01:01:00 01:02:00 01:02:00 01:02:00 01:02:00 03:00:00 }
      '';
    })

    (mkIf cfg.bigscreen {
      services.udev.extraRules = ''
        # Bigscreen Beyond
        KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="35bd", ATTRS{idProduct}=="0101", MODE="0660", GROUP="users"
        # Bigscreen Bigeye
        KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="35bd", ATTRS{idProduct}=="0202", MODE="0660", GROUP="users"
        # Bigscreen Beyond Audio Strap
        KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="35bd", ATTRS{idProduct}=="0105", MODE="0660", GROUP="users"
        # Bigscreen Beyond Firmware Mode?
        KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="35bd", ATTRS{idProduct}=="4004", MODE="0660", GROUP="users"
      '';
    })

    (mkIf cfg.corne {
      services.usbguard.rules = ''
        allow id 1d50:615e serial "7E9C97C092E11E0A" name "Corne" hash "F1i6fSRQyssfm7PAtDBNxR3tzdarO+2Gz0aEjz5/9Og=" with-interface 03:00:00
      '';
      services.udev.extraRules = ''
        # SYMLINK also creates a .device with the path of the symlink, i.e. `dev-corne.device`
        ACTION=="add", KERNEL=="event*", SUBSYSTEM=="input", ATTRS{id/vendor}=="1d50", ATTRS{id/product}=="615e", ATTRS{name}=="Corne Keyboard", SYMLINK+="corne", TAG+="systemd", ENV{SYSTEMD_WANTS}="wireless-keyboard.target"
      '';
    })

    (mkIf cfg.dac {
      services.usbguard.rules = ''
        allow id 0bda:4c07 serial "" name "TX-384Khz Hifi Type-C Audio" hash "9yKCsVifCIoMIuAZNQhzX8KKJmghaIMGcDWXemiMzHQ=" with-interface { 01:01:20 01:02:20 01:02:20 01:02:20 01:02:20 03:00:00 } with-connect-type "not used"
      '';
    })

    (mkIf cfg.elektron {
      services.usbguard.rules = ''
        allow id 1935:102b serial "000000000001" name "Elektron Digitakt II" hash "qhmC0G+vsuzFsGWypvwiQ99fqIXgYejjChjBO6hcx3I=" with-interface { 01:01:20 01:02:20 01:02:20 01:02:20 01:02:20 01:01:00 01:03:00 }
        allow id 1935:1034 serial "000000000001" name "Elektron Digitone II" hash "8yAKxPDjwh0CeTCnFUtjFU6r6FfxVZ8q0Jwk7OQelZk=" with-interface { 01:01:20 01:02:20 01:02:20 01:02:20 01:02:20 01:01:00 01:03:00 }
      '';
    })

    (mkIf cfg.ftdi {
      services.usbguard.rules = ''
        allow id 0403:6001 name "FT232R USB UART" with-interface ff:ff:ff with-connect-type "unknown"
        allow id 0403:6010 serial "" name "Dual RS232" hash "tn0uCA4k10/s1Byx8ctfTF7bYUnza4P81ry5wbcmiyY=" with-interface equals { ff:ff:ff ff:ff:ff } with-connect-type "unknown"
      '';
    })

    (mkIf cfg.jetson {
      services.usbguard.rules = ''
        allow id 0955:7e19 name "APX" with-interface ff:ff:ff with-connect-type "unknown" # Jetson
      '';
    })

    (mkIf cfg.nxpimx {
      services.usbguard.rules = ''
        allow id 0525:a4a2 serial "" name "RNDIS/Ethernet Gadget" hash "VtfbWFxVs6nMUHJ2hSFVw9A2aqtbUZ4i97rFBoFDG38=" with-interface equals { 02:02:ff 0a:00:00 02:06:00 0a:00:00 0a:00:00 } with-connect-type "unknown" # NXP
      '';
      services.udev.extraRules = ''
        # IMX usb ethernet
        ACTION=="add", SUBSYSTEM=="net", SUBSYSTEMS=="usb", ATTRS{idVendor}=="0525", ATTRS{idProduct}=="a4a2", NAME="nxpeth%n"
      '';

      networking.firewall.trustedInterfaces = [ "nxpeth0" ];
      networking.networkmanager.ensureProfiles.profiles = {
        "NXP Ethernet" = {
          connection = {
            autoconnect = true;
            id = "NXP Ethernet";
            interface-name = "nxpeth0"; # TODO: set name from udev
            type = "ethernet";
          };
          ethernet = { };
          ipv4 = {
            method = "shared";
            # Pin the host-side address/subnet instead of letting NM auto-pick 10.42.x.0/24
            address1 = "10.42.0.1/24";
            shared-dhcp-range = "10.42.0.2,10.42.0.2"; # Device IP
            shared-dhcp-lease-time = "2147483647"; # 2^31
          };
          ipv6 = {
            method = "link-local"; # Keep IPv6 link-local alive on the USB link
          };
          proxy = { };
        };
      };
    })

    (mkIf cfg.pixel10 {
      services.usbguard.rules = ''
        allow id 18d1:4ee0 serial "59120DLCQ005A6" name "Pixel 10 Pro XL" hash "FmAp0eGmtgwF8/sGkm2vOLPA9KbmuqqjUuAZA3xauv0=" with-interface ff:42:03 with-connect-type "not used" # fastboot
        allow id 18d1:4ee7 serial "59120DLCQ005A6" name "Pixel 10 Pro XL" hash "EWaGWgjqbyIHtGwqAFfWw44MOmjFAWK00eRExteS/OQ=" with-interface ff:42:01 with-connect-type "not used" # adb
      '';
    })

    (mkIf cfg.yubico {
      users.users.${username}.extraGroups = [ "yubihsm" ];
      users.groups = {
        yubihsm = { };
      };
      services.udev = {
        enable = true;
        packages = with pkgs; [
          yubikey-personalization # needed for yubikey-manager
        ];
        extraRules = ''
          # yubihsm
          SUBSYSTEM=="usb", ATTR{idVendor}=="1050", ATTR{idProduct}=="0030", MODE="0660", GROUP="yubihsm"
        '';
      };
      services.usbguard.rules = ''
        allow id 1050:0402 serial "" name "YubiKey FIDO" hash "ZZ2J/ZgNx0xMmsjwUrSVnZ4BdrM/RSDsfjrYRCmvoME=" with-interface 03:00:00
      '';
    })

    # must be last
    {
      services.usbguard.rules = ''
        # Block everything else
        block id *:*
      '';
    }
  ]);
}
