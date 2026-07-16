{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchNpmDeps,
  fetchPnpmDeps,
  makeDesktopItem,

  autoPatchelfHook,
  copyDesktopItems,
  makeWrapper,
  nodejs_22,
  npmHooks,
  pnpmConfigHook,
  pnpm_10,

  electron,
}:

let
  pnpm = pnpm_10.override { nodejs = nodejs_22; };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "chatbox";
  version = "1.21.1";

  src = fetchFromGitHub {
    owner = "chatboxai";
    repo = "chatbox";
    tag = "v${finalAttrs.version}";
    hash = "sha256-9ZcBNGSvaSMy2J14K7KfEtNVDbvJLILS9ula0D75CSk=";
  };

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    inherit pnpm;
    fetcherVersion = 3;
    hash = "sha256-iDgzryN61MnZFzdxUg/SApTPZV/jLWyDNFHOO0lahIw=";
  };

  extraNpmDeps = fetchNpmDeps {
    name = "${finalAttrs.pname}-${finalAttrs.version}-runtime-deps";
    inherit (finalAttrs) src;
    sourceRoot = "${finalAttrs.src.name}/release/app";
    hash = "sha256-JrnX5NZFwk+i/Zdi1v2SY0LBTwZUVOPv6L8Bhl/ceMM=";
  };

  postPatch = ''
    # Use the pnpm provided by nixpkgs instead of letting pnpm download the
    # packageManager version named by package.json.
    sed -i 's#"packageManager":.*#"packageManager": "pnpm@${pnpm.version}"#' package.json

    # Nix installs release/app's dependencies offline before the build. Disable
    # upstream's beforePack hook, which deletes them and runs npm against a
    # network registry.
    substituteInPlace electron-builder.yml \
      --replace-fail "beforePack: .erb/scripts/ensure-app-deps.cjs" \
                     "# beforePack is handled by the Nix derivation"
  '';

  env = {
    ELECTRON_SKIP_BINARY_DOWNLOAD = "1";
    UPDATE_CHANNEL = "stable";
  };

  npmRebuildFlags = [ "--ignore-scripts" ];

  nativeBuildInputs = [
    autoPatchelfHook
    copyDesktopItems
    makeWrapper
    nodejs_22
    pnpmConfigHook
    pnpm
  ];

  buildInputs = [
    stdenv.cc.cc
  ];

  autoPatchelfIgnoreMissingDeps = [
    "libc.musl-aarch64.so.1"
    "libc.musl-x86_64.so.1"
  ];

  preBuild = ''
    pushd release/app
    rm -rf node_modules
    source ${npmHooks.npmConfigHook}/nix-support/setup-hook
    npmDeps="$extraNpmDeps" npmConfigHook
    node ../../.erb/scripts/patch-libsql.cjs
    popd
  '';

  buildPhase = ''
    runHook preBuild

    pnpm run build

    cp -r ${electron.dist} electron-dist
    chmod -R u+w electron-dist

    pnpm exec electron-builder \
      --dir \
      --config=electron-builder.yml \
      -c.electronDist=electron-dist \
      -c.electronVersion=${electron.version}

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    for icon in assets/icons/*.png; do
      size=$(basename "$icon" .png)
      install -Dm644 "$icon" "$out/share/icons/hicolor/$size/apps/chatbox.png"
    done

    mkdir -p $out/share/chatbox
    cp -r release/build/*-unpacked/{locales,resources{,.pak}} $out/share/chatbox

    makeWrapper ${lib.getExe electron} $out/bin/chatbox \
      --set-default ELECTRON_FORCE_IS_PACKAGED 1 \
      --add-flags $out/share/chatbox/resources/app.asar \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations}}" \
      --inherit-argv0

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "chatbox";
      desktopName = "Chatbox";
      comment = finalAttrs.meta.description;
      exec = "chatbox";
      icon = "chatbox";
      categories = [ "Development" ];
    })
  ];

  meta = {
    description = "Desktop client for ChatGPT, Claude, and other LLMs";
    homepage = "https://github.com/chatboxai/chatbox";
    changelog = "https://github.com/chatboxai/chatbox/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Only;
    mainProgram = "chatbox";
    platforms = lib.platforms.linux;
    sourceProvenance = with lib.sourceTypes; [
      binaryNativeCode
    ];
  };
})
