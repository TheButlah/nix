{
  enable = true;
  rules = ''
    # Generic classes
    allow with-interface equals { 09:00:* } # usb hubs
    allow with-interface equals { 09:00:* 09:00:* } # usb hubs w multiple protocols
    allow with-interface equals { 08:*:* } # Mass storage
    allow with-interface equals { 08:*:* 08:*:* } # Mass storage with multiple protocols
    allow with-interface equals { 01:*:* } # Audio
    allow with-interface equals { 11:*:* } # Billboard devices

    # Specific devices
    allow id 1050:0402 serial "" name "YubiKey FIDO" hash "ZZ2J/ZgNx0xMmsjwUrSVnZ4BdrM/RSDsfjrYRCmvoME=" with-interface 03:00:00
    allow id 0909:001c serial "" name "AT2020USB+" hash "/Rj52epXXbngHHurEDmdeKQOn/F9aYSO4ChFo/Snpgo=" with-interface { 01:01:00 01:02:00 01:02:00 01:02:00 01:02:00 03:00:00 }
    allow id 1935:102b serial "000000000001" name "Elektron Digitakt II" hash "qhmC0G+vsuzFsGWypvwiQ99fqIXgYejjChjBO6hcx3I=" with-interface { 01:01:20 01:02:20 01:02:20 01:02:20 01:02:20 01:01:00 01:03:00 }
    allow id 0bda:4c07 serial "" name "TX-384Khz Hifi Type-C Audio" hash "9yKCsVifCIoMIuAZNQhzX8KKJmghaIMGcDWXemiMzHQ=" with-interface { 01:01:20 01:02:20 01:02:20 01:02:20 01:02:20 03:00:00 } with-connect-type "not used"
    allow id 1d50:615e serial "7E9C97C092E11E0A" name "Corne" hash "F1i6fSRQyssfm7PAtDBNxR3tzdarO+2Gz0aEjz5/9Og=" with-interface 03:00:00
    allow id 18d1:4ee0 serial "59120DLCQ005A6" name "Pixel 10 Pro XL" hash "FmAp0eGmtgwF8/sGkm2vOLPA9KbmuqqjUuAZA3xauv0=" with-interface ff:42:03 with-connect-type "not used" # fastboot
    allow id 18d1:4ee7 serial "59120DLCQ005A6" name "Pixel 10 Pro XL" hash "EWaGWgjqbyIHtGwqAFfWw44MOmjFAWK00eRExteS/OQ=" with-interface ff:42:01 with-connect-type "not used" # adb
    allow id 0403:6001 name "FT232R USB UART" with-interface ff:ff:ff with-connect-type "unknown"
    allow id 0955:7e19 name "APX" with-interface ff:ff:ff with-connect-type "unknown" # Jetson
    allow id 0525:a4a2 serial "" name "RNDIS/Ethernet Gadget" hash "VtfbWFxVs6nMUHJ2hSFVw9A2aqtbUZ4i97rFBoFDG38=" with-interface equals { 02:02:ff 0a:00:00 02:06:00 0a:00:00 0a:00:00 } with-connect-type "unknown" # NXP
    allow id 0403:6010 serial "" name "Dual RS232" hash "tn0uCA4k10/s1Byx8ctfTF7bYUnza4P81ry5wbcmiyY=" with-interface equals { ff:ff:ff ff:ff:ff } with-connect-type "unknown"


    # Block everything else
    block id *:*
  '';
  implicitPolicyTarget = "block";
  presentDevicePolicy = "apply-policy";
  presentControllerPolicy = "keep";
  insertedDevicePolicy = "apply-policy";
}
