{
  lib,
  psp-libpspvram,
  psp-pspgl,
  fetchurl,
  pspMkLibraryDerivation,
}:

pspMkLibraryDerivation rec {
  pname = "psp-sdl3";
  version = "3.4.12";
  src = fetchurl {
    url = "https://github.com/libsdl-org/SDL/archive/refs/tags/release-${version}.tar.gz";
    hash = "sha256-toOB8Gp1gOY0ALO261R+xX2MPr3nD59A4KulMLoF2ic=";
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
    description = "Simple DirectMedia Layer 3";
    homepage = "https://www.libsdl.org/";
    license = lib.licenses.zlib;
    platforms = lib.platforms.all;
  };
}
