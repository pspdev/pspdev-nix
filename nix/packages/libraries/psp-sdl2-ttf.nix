{
  lib,
  fetchFromGitHub,
  SDL2_ttf,
  psp-pkg-config,
  psp-sdl2,
  pspMkLibraryDerivation,
}:

pspMkLibraryDerivation rec {
  pname = "psp-sdl2-ttf";
  inherit (SDL2_ttf) version;

  src = fetchFromGitHub {
    owner = "libsdl-org";
    repo = "SDL_ttf";
    rev = "release-${version}";
    hash = "sha256-wm3ANV/XjLkoZBca/iClHsfXUd8w5x/VeI+EUDLHvkQ=";
    fetchSubmodules = true;
  };

  buildSystem = "custom";

  nativeBuildInputs = [ psp-pkg-config ];

  buildInputs = [
    psp-sdl2
  ];

  dontConfigure = false;

  configureFlags = [
    "CC=psp-gcc"
    "CXX=psp-g++"
    "--prefix=/psp"
    "--host=psp"
    "--disable-shared"
    "--enable-static"
    (lib.enableFeature true "harfbuzz-builtin")
    (lib.enableFeature true "freetype-builtin")
    (lib.enableFeature false "sdltest")
  ];

  postPatch = ''
    cat > external/harfbuzz/config.h <<'EOF'
    #ifndef HARFBUZZ_CONFIG_H
    #define HARFBUZZ_CONFIG_H
    #define HAVE_STDINT_H 1
    #define HAVE_INTTYPES_H 1
    #define HAVE_UNISTD_H 1
    #define HAVE_STDBOOL_H 1
    #endif
    EOF
  '';

  configurePhase = ''
        runHook preConfigure

        export PKG_CONFIG=psp-pkg-config
        cat > sdl2-config <<EOF
        #!/bin/sh
        case "$1" in
          --version) echo "2.32.10" ;;
          --cflags) echo "-I${psp-sdl2}/psp/include/SDL2" ;;
          --libs|--static-libs) echo "-L${psp-sdl2}/psp/lib -lSDL2" ;;
          --prefix|--exec-prefix) echo "/psp" ;;
          --libdir) echo "/psp/lib" ;;
          --includedir) echo "/psp/include/SDL2" ;;
          *) exit 0 ;;
        esac
    EOF
        chmod +x sdl2-config
        export SDL_CONFIG=$PWD/sdl2-config
        export SDL2_CONFIG=$PWD/sdl2-config
        export CPPFLAGS="-I${psp-sdl2}/psp/include/SDL2"
        export LDFLAGS="-L${psp-sdl2}/psp/lib"
        export PKG_CONFIG=${psp-pkg-config}/bin/psp-pkg-config
        export cross_compiling=yes
        ./configure ${lib.escapeShellArgs configureFlags}

        runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild

    make -j$NIX_BUILD_CORES libSDL2_ttf.la

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/psp/include/SDL2" "$out/psp/lib"
    install -m644 .libs/libSDL2_ttf.a "$out/psp/lib/"
    install -m644 SDL_ttf.h "$out/psp/include/SDL2/"

    runHook postInstall
  '';

  doCheck = false;

  meta = {
    inherit (SDL2_ttf.meta) description homepage license;
    platforms = lib.platforms.all;
  };
}
