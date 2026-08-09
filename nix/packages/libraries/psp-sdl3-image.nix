{
  lib,
  psp-libpng,
  psp-libjpeg,
  psp-libwebp,
  psp-libtiff,
  psp-pkg-config,
  psp-sdl3,
  psp-zlib,
  fetchurl,
  pspMkLibraryDerivation,
  stdenv,
  # Boolean flags
  enableTests ? false,
  enableSTB ? true,
  enableImageIO ? false,
}:

pspMkLibraryDerivation rec {
  pname = "psp-sdl3-image";
  version = "3.4.4";
  src = fetchurl {
    url = "https://github.com/libsdl-org/SDL_image/archive/refs/tags/release-${version}.tar.gz";
    hash = "sha256-sMEbveVA4m0c7fMRdDSf5qtn5XZY7+IuFudRcoWcgX0=";
  };

  buildSystem = "cmake";

  nativeBuildInputs = [
    psp-pkg-config
  ];

  buildInputs = [
    psp-sdl3
    psp-libtiff
    psp-libwebp
    psp-libjpeg
    psp-zlib
    psp-libpng
  ];

  cmakeFlags = [
    "-DCMAKE_INSTALL_PREFIX=/psp"
    "-DSDL3_DIR=${psp-sdl3}/psp/lib/cmake/SDL3"
    "-DBUILD_SHARED_LIBS=OFF"
    "-DCMAKE_PREFIX_PATH=${psp-libjpeg}/psp;${psp-libpng}/psp;${psp-libtiff}/psp;${psp-libwebp}/psp"
    "-DJPEG_LIBRARY=${psp-libjpeg}/psp/lib/libjpeg.a"
    "-DJPEG_INCLUDE_DIR=${psp-libjpeg}/psp/include"
    "-DPNG_LIBRARY=${psp-libpng}/psp/lib/libpng.a"
    "-DPNG_PNG_INCLUDE_DIR=${psp-libpng}/psp/include"
    "-DZLIB_LIBRARY=${psp-zlib}/psp/lib/libz.a"
    "-DZLIB_INCLUDE_DIR=${psp-zlib}/psp/include"
    "-DTIFF_LIBRARY=${psp-libtiff}/psp/lib/libtiff.a"
    "-DTIFF_INCLUDE_DIR=${psp-libtiff}/psp/include"
    "-Dwebp_LIBRARY=${psp-libwebp}/psp/lib/libwebp.a"
    "-Dwebp_INCLUDE_PATH=${psp-libwebp}/psp/include"
    "-Dwebpdemux_LIBRARY=${psp-libwebp}/psp/lib/libwebpdemux.a"
    "-Dwebpdemux_INCLUDE_PATH=${psp-libwebp}/psp/include"
    "-Dwebpmux_LIBRARY=${psp-libwebp}/psp/lib/libwebpmux.a"
    "-Dwebpmux_INCLUDE_PATH=${psp-libwebp}/psp/include"
    (lib.cmakeBool "SDLIMAGE_VENDORED" false)
    (lib.cmakeBool "SDLIMAGE_STRICT" true)
    (lib.cmakeBool "SDLIMAGE_AVIF" false)
    (lib.cmakeBool "SDLIMAGE_TIF" true)
    (lib.cmakeBool "SDLIMAGE_WEBP" true)
    (lib.cmakeBool "SDLIMAGE_BACKEND_STB" false)
    (lib.cmakeBool "SDLIMAGE_SAMPLES" false)
    (lib.cmakeBool "SDLIMAGE_TESTS" enableTests)
    (lib.cmakeBool "SDLIMAGE_INSTALL" true)
  ];

  doCheck = false;

  installPhase = ''
    runHook preInstall

    DESTDIR="$out" cmake --install build

    runHook postInstall
  '';

  meta = {
    description = "Image loading library for SDL3";
    homepage = "https://github.com/libsdl-org/SDL_image";
    license = lib.licenses.zlib;
    platforms = lib.platforms.all;
  };
}
