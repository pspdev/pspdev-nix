{
  lib,
  fetchurl,
  psp-libpng,
  psp-libjpeg,
  psp-libwebp,
  psp-libtiff,
  psp-sdl2,
  psp-pkg-config,
  psp-zlib,
  pspMkLibraryDerivation,
  stdenv,
  # Boolean flags
  enableSTB ? true,
  enableSdltest ? (!stdenv.hostPlatform.isDarwin),
}:

pspMkLibraryDerivation rec {
  pname = "psp-sdl2-image";
  version = "2.8.12";
  src = fetchurl {
    url = "https://www.libsdl.org/projects/SDL_image/release/SDL2_image-${version}.tar.gz";
    hash = "sha256-OT9e+1BTbsE8pPSv+2nMmWbTw/lp5sXnAfrd+fl4U4E=";
  };

  buildSystem = "custom";

  nativeBuildInputs = [
    psp-pkg-config
  ];

  buildInputs = [
    psp-sdl2
    psp-libtiff
    psp-libwebp
    psp-libjpeg
    psp-zlib
    psp-libpng
  ];

  dontConfigure = false;

  configureFlags = [
    "CC=psp-gcc"
    "--prefix=/psp"
    "--host=psp"
    "--disable-shared"
    "--enable-static"
    (lib.enableFeature false "jpg-shared")
    (lib.enableFeature false "png-shared")
    (lib.enableFeature false "tif-shared")
    (lib.enableFeature false "webp-shared")
    (lib.enableFeature enableSTB "stb-image")
    (lib.enableFeature enableSdltest "tests")
    (lib.enableFeature false "installed-tests")
  ];

  configurePhase = ''
    runHook preConfigure

    export PKG_CONFIG_PATH=${psp-sdl2}/psp/lib/pkgconfig''${PKG_CONFIG_PATH:+:$PKG_CONFIG_PATH}
    export SDL_CONFIG=${psp-sdl2}/psp/bin/sdl2-config
    export SDL2_CONFIG=${psp-sdl2}/psp/bin/sdl2-config
    export CPPFLAGS=-I${psp-sdl2}/psp/include/SDL2
    export LDFLAGS=-L${psp-sdl2}/psp/lib
    export cross_compiling=yes
    ./configure ${lib.escapeShellArgs configureFlags}

    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild

    make -j$NIX_BUILD_CORES libSDL2_image.la

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -Dm644 include/SDL_image.h "$out/psp/include/SDL2/SDL_image.h"
    make DESTDIR="$out" \
      install-libLTLIBRARIES \
      install-pkgconfigDATA \
      install-data-local

    runHook postInstall
  '';

  doCheck = false;

  meta = {
    description = "Image loading library for SDL2";
    homepage = "https://github.com/libsdl-org/SDL_image";
    license = lib.licenses.zlib;
    platforms = lib.platforms.all;
  };
}
