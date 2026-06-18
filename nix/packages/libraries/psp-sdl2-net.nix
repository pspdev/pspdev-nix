{
  lib,
  SDL2_net,
  psp-sdl2,
  psp-pkg-config,
  pspMkLibraryDerivation,
  stdenv,
}:

pspMkLibraryDerivation rec {
  pname = "psp-sdl2-net";
  inherit (SDL2_net) version src;

  buildSystem = "custom";

  nativeBuildInputs = [
    psp-pkg-config
  ];

  buildInputs = [
    psp-sdl2
  ];

  dontConfigure = false;

  configureFlags = [
    "CC=psp-gcc"
    "--prefix=/psp"
    "--host=psp"
    "--disable-shared"
    "--enable-static"
    (lib.enableFeature false "examples")
    (lib.enableFeature false "sdltest")
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

  postPatch = ''
    substituteInPlace SDLnetsys.h \
      --replace-fail '#include <net/if.h>' '/* PSP: net/if.h unavailable */'
  '';

  buildPhase = ''
    runHook preBuild

    make -j$NIX_BUILD_CORES

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    make DESTDIR="$out" install

    runHook postInstall
  '';

  doCheck = false;

  meta = {
    inherit (SDL2_net.meta) description homepage license;
    platforms = lib.platforms.all;
  };
}
