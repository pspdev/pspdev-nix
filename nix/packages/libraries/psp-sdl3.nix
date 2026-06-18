{
  lib,
  psp-libpspvram,
  psp-pspgl,
  sdl3,
  pspMkLibraryDerivation,
}:

pspMkLibraryDerivation rec {
  pname = "psp-sdl3";
  inherit (sdl3) version src;

  buildSystem = "cmake";

  buildInputs = [
    psp-libpspvram
    psp-pspgl
  ];

  cmakeFlags = [
    "-DCMAKE_INSTALL_PREFIX=/psp"
    "-DBUILD_SHARED_LIBS=OFF"
    "-DSDL_TESTS=OFF"
    "-DSDL_INSTALL_TESTS=OFF"
    "-DSDL_TEST_LIBRARY=OFF"
    "-DSDL_DEPS_SHARED=OFF"
  ];

  doCheck = false;

  installPhase = ''
    runHook preInstall

    DESTDIR="$out" cmake --install build

    runHook postInstall
  '';

  meta = {
    inherit (sdl3.meta) description homepage license;
    platforms = lib.platforms.all;
  };
}
