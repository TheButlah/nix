{
  enable = true;
  rules = ''
    # Generic classes
    allow with-interface equals { 09:00:* } # usb hubs
    allow with-interface equals { 09:00:* 09:00:* } # usb hubs w multiple protocols
    allow with-interface equals { 08:*:* } # Mass storage
    allow with-interface equals { 08:*:* 08:*:* } # Mass storage with multiple protocols
    allow with-interface equals { 01:*:* } # Audio

    # Specific devices
    allow id 1050:0402 serial "" name "YubiKey FIDO" hash "ZZ2J/ZgNx0xMmsjwUrSVnZ4BdrM/RSDsfjrYRCmvoME=" with-interface 03:00:00
    allow id 0909:001c serial "" name "AT2020USB+" hash "/Rj52epXXbngHHurEDmdeKQOn/F9aYSO4ChFo/Snpgo=" with-interface { 01:01:00 01:02:00 01:02:00 01:02:00 01:02:00 03:00:00 }
    allow id 1935:102b serial "000000000001" name "Elektron Digitakt II" hash "qhmC0G+vsuzFsGWypvwiQ99fqIXgYejjChjBO6hcx3I=" with-interface { 01:01:20 01:02:20 01:02:20 01:02:20 01:02:20 01:01:00 01:03:00 }
    allow id 1d50:615e serial "7E9C97C092E11E0A" name "Corne" hash "F1i6fSRQyssfm7PAtDBNxR3tzdarO+2Gz0aEjz5/9Og=" with-interface 03:00:00
    allow id 18d1:4ee7 serial "58090DLCQ0093E" name "Pixel 10 Pro XL" hash "aoBAkQgPrRbdl2CN9oDebYxvbZlLogW8Sudy6Vw7wfA=" parent-hash "zPEgphy8DinLP2QQPlh78r65kXqs8tTFSkoXXpgrIC8=" with-interface ff:42:01
    allow id 18d1:4ee7 serial "5B050DLCH001R5" name "Pixel 10 Pro" hash "LGVFvuo13/JjyH4qptG90vFwYJzwuLrpAJcEJjVMWCY=" parent-hash "zPEgphy8DinLP2QQPlh78r65kXqs8tTFSkoXXpgrIC8=" via-port "1-1" with-interface ff:42:01 with-connect-type "not used"
    allow id 0403:6001 name "FT232R USB UART" with-interface ff:ff:ff with-connect-type "unknown"
    allow id 0955:7e19 name "APX" with-interface ff:ff:ff with-connect-type "unknown" # Jetson


    # Block everything else
    block id *:*
  '';
  implicitPolicyTarget = "block";
  presentDevicePolicy = "apply-policy";
  presentControllerPolicy = "keep";
  insertedDevicePolicy = "apply-policy";
}
