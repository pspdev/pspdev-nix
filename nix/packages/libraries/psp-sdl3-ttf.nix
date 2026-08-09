{
  lib,
  fetchFromGitHub,
  psp-freetype,
  psp-harfbuzz,
  psp-sdl3,
  pspMkLibraryDerivation,
}:

pspMkLibraryDerivation rec {
  pname = "psp-sdl3-ttf";
  version = "3.2.2";

  src = fetchFromGitHub {
    owner = "libsdl-org";
    repo = "SDL_ttf";
    rev = "release-${version}";
    hash = "sha256-1Gc71BRs6WcPpS2iNXPoCVaPP8dxH/fQ6tyeeqZC09k=";
    fetchSubmodules = true;
  };

  buildSystem = "cmake";

  buildInputs = [
    psp-sdl3
    psp-freetype
    psp-harfbuzz
  ];

  cmakeFlags = [
    "-DCMAKE_INSTALL_PREFIX=/psp"
    "-DSDL3_DIR=${psp-sdl3}/psp/lib/cmake/SDL3"
    "-Dharfbuzz_LIBRARY=${psp-harfbuzz}/psp/lib/libharfbuzz.a"
    "-Dharfbuzz_INCLUDE_PATH=${psp-harfbuzz}/psp/include/harfbuzz"
    "-DFREETYPE_LIBRARY=${psp-freetype}/psp/lib/libfreetype.a"
    "-DFREETYPE_INCLUDE_DIRS=${psp-freetype}/psp/include/freetype2"
    "-DBUILD_SHARED_LIBS=OFF"
    (lib.cmakeBool "SDLTTF_INSTALL" true)
    (lib.cmakeBool "SDLTTF_STRICT" true)
    (lib.cmakeBool "SDLTTF_VENDORED" false)
    (lib.cmakeBool "SDLTTF_HARFBUZZ" true)
    (lib.cmakeBool "SDLTTF_SAMPLES" false)
    (lib.cmakeBool "SDLTTF_PLUTOSVG" false)
  ];

  doCheck = false;

  installPhase = ''
    runHook preInstall

    DESTDIR="$out" cmake --install build

    runHook postInstall
  '';

  meta = {
    description = "TrueType font library for SDL3";
    homepage = "https://github.com/libsdl-org/SDL_ttf";
    license = lib.licenses.zlib;
    platforms = lib.platforms.all;
  };
}
