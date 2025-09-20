{
  enable = true;
  rules = ''
    # Generic classes
    allow with-interface equals { 09:00:* } # usb hubs
    allow with-interface equals { 08:*:* } # Mass storage
    allow with-interface equals { 08:*:* 08:*:* } # Mass storage with multiple protocols

    # Specific devices
    allow id 1050:0402 serial "" name "YubiKey FIDO" hash "ZZ2J/ZgNx0xMmsjwUrSVnZ4BdrM/RSDsfjrYRCmvoME=" with-interface 03:00:00
    allow id 0909:001c serial "" name "AT2020USB+" hash "/Rj52epXXbngHHurEDmdeKQOn/F9aYSO4ChFo/Snpgo=" with-interface { 01:01:00 01:02:00 01:02:00 01:02:00 01:02:00 03:00:00 }
    allow id 1935:102b serial "000000000001" name "Elektron Digitakt II" hash "qhmC0G+vsuzFsGWypvwiQ99fqIXgYejjChjBO6hcx3I=" with-interface { 01:01:20 01:02:20 01:02:20 01:02:20 01:02:20 01:01:00 01:03:00 }

    # Block everything else
    block id *:*
  '';
  implicitPolicyTarget = "block";
  presentDevicePolicy = "apply-policy";
  presentControllerPolicy = "keep";
  insertedDevicePolicy = "apply-policy";
}
