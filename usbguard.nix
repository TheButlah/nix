{
  enable = true;
  rules = ''
    allow with-interface equals { 09:00:* } # usb hubs
    allow with-interface equals { 08:*:* } # Mass storage
    allow with-interface equals { 08:*:* 08:*:* } # Mass storage with multiple protocols

    allow id 1050:0402 serial "" name "YubiKey FIDO" hash "ZZ2J/ZgNx0xMmsjwUrSVnZ4BdrM/RSDsfjrYRCmvoME=" with-interface 03:00:00

    # Block everything else
    block id *:*
  '';
  implicitPolicyTarget = "block";
  presentDevicePolicy = "apply-policy";
  presentControllerPolicy = "keep";
  insertedDevicePolicy = "apply-policy";
}
