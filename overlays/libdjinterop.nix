# Fixes https://github.com/NixOS/nixpkgs/issues/422551
self: super: {
  libdjinterop = super.libdjinterop.overrideAttrs (oldAttrs: rec {
    cmakeFlags = (oldAttrs.cmakeFlags or [ ]) ++ [
      "-DCMAKE_C_FLAGS=-Wno-error=stringop-overflow"
      "-DCMAKE_CXX_FLAGS=-Wno-error=stringop-overflow"
    ];
  });
}
