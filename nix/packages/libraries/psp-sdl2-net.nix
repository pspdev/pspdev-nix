{
  lib,
  fetchFromGitHub,
  psp-sdl2,
  psp-pkg-config,
  pspMkLibraryDerivation,
}:

pspMkLibraryDerivation rec {
  pname = "psp-sdl2-net";
  version = "2.4.0";
  src = fetchFromGitHub {
    owner = "libsdl-org";
    repo = "SDL_net";
    rev = "release-${version}";
    hash = "sha256-FDJT5RPoquC527K0wG9IPouea6P3lwhHPqj29sZXMuw=";
  };

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
    description = "Networking library for SDL2";
    homepage = "https://github.com/libsdl-org/SDL_net";
    license = lib.licenses.zlib;
    platforms = lib.platforms.all;
  };
}
