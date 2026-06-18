{
  lib,
  fetchFromGitHub,
  pspMkLibraryDerivation,
}:

pspMkLibraryDerivation rec {
  pname = "psp-libpspvram";
  version = "r11.885fd3f";

  src = fetchFromGitHub {
    owner = "pspdev";
    repo = "libpspvram";
    rev = "885fd3f5420dbc6a9ed450d268d752813093b417";
    hash = "sha256-cyeuVwOkjdiKPe2hRdmPE0DaFT6aRSXGWvyguesHcHA=";
  };

  buildSystem = "cmake";

  cmakeFlags = [
    "-DCMAKE_INSTALL_PREFIX=/psp"
    "-DCMAKE_BUILD_TYPE=Release"
    "-DCMAKE_POLICY_VERSION_MINIMUM=3.5"
  ];

  installPhase = ''
    runHook preInstall

    DESTDIR="$out" cmake --install build

    install -Dm644 vram.h "$out/psp/include/vram.h"
    install -Dm644 vramalloc.h "$out/psp/include/vramalloc.h"

    runHook postInstall
  '';

  doCheck = false;

  meta = {
    description = "Dynamic VRAM allocation manager for the PSP";
    homepage = "https://github.com/albe/libpspvram";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
}
