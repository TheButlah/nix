{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  dbus,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "svrbsctl";
  version = "0.2.4";

  src = fetchFromGitHub {
    owner = "chenxiaolong";
    repo = finalAttrs.pname;
    rev = "v${finalAttrs.version}";
    hash = "sha256-qW1rmSMwXKUR5lDF2xae/oE9SIHaMW7xKmZgbIfDi+0=";
  };

  cargoHash = "sha256-RluVmEDtfos4SUdcH8PxJG0bbX4jkCRfPZz8jHxhjGo=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    dbus
  ];

  meta = {
    description = "Simple tool to control the operating state of SteamVR 2.0 Base Stations";
    homepage = "https://github.com/chenxiaolong/svrbsctl";
    license = lib.licenses.gpl3Only;
    mainProgram = finalAttrs.pname;
    platforms = lib.platforms.linux;
  };
})
