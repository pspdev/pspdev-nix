{
  lib,
  fetchurl,
  SDL2,
  psp-libpspvram,
  psp-pspgl,
  pspMkLibraryDerivation,
}:

pspMkLibraryDerivation rec {
  pname = "psp-sdl2";
  version = "2.32.10";

  src = fetchurl {
    url = "https://github.com/libsdl-org/SDL/releases/download/release-${version}/SDL2-${version}.tar.gz";
    hash = "sha256-X1mTxTDwhFNcZaaHnpsmrUQRabPiXXidgyhwQKnKUWU=";
  };

  buildSystem = "cmake";

  buildInputs = [
    psp-libpspvram
    psp-pspgl
  ];

  cmakeFlags = [
    "-DCMAKE_INSTALL_PREFIX=/psp"
    "-DBUILD_SHARED_LIBS=OFF"
    "-DSDL_TESTS=OFF"
    "-DSDL_TEST=OFF"
  ];

  doCheck = false;

  installPhase = ''
    runHook preInstall

    DESTDIR="$out" cmake --install build

    runHook postInstall
  '';

  meta = {
    inherit (SDL2.meta) description homepage license;
    platforms = lib.platforms.all;
  };
}
