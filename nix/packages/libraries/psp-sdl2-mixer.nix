{
  lib,
  fetchFromGitHub,
  psp-sdl2,
  psp-pkg-config,
  pspMkLibraryDerivation,
}:

pspMkLibraryDerivation rec {
  pname = "psp-sdl2-mixer";
  version = "2.8.2";
  src = fetchFromGitHub {
    owner = "libsdl-org";
    repo = "SDL_mixer";
    rev = "release-${version}";
    hash = "sha256-ln2RncnKbHIqvFia/ZlnbOGoVDJV8gF3538Wft3/wrw=";
  };

  buildSystem = "cmake";

  nativeBuildInputs = [
    psp-pkg-config
  ];

  buildInputs = [ psp-sdl2 ];

  cmakeFlags = [
    "-DCMAKE_INSTALL_PREFIX=/psp"
    "-DSDL2_DIR=${psp-sdl2}/psp/lib/cmake/SDL2"
    "-DCMAKE_PREFIX_PATH=${psp-sdl2}/psp"
    "-DBUILD_SHARED_LIBS=OFF"
    "-DCMAKE_POSITION_INDEPENDENT_CODE=OFF"
    "-DSDL2MIXER_VENDORED=OFF"
    "-DSDL2MIXER_CMD=OFF"
    "-DSDL2MIXER_MOD=OFF"
    "-DSDL2MIXER_MP3=OFF"
    "-DSDL2MIXER_MIDI=OFF"
    "-DSDL2MIXER_FLAC_DRFLAC=OFF"
    "-DSDL2MIXER_GME=OFF"
    "-DSDL2MIXER_MOD_XMP=OFF"
    "-DSDL2MIXER_MP3_MINIMP3=OFF"
    "-DSDL2MIXER_MIDI_TIMIDITY=OFF"
    "-DSDL2MIXER_MIDI_FLUIDSYNTH=OFF"
    "-DSDL2MIXER_OPUS=OFF"
    "-DSDL2MIXER_VORBIS=OFF"
    "-DSDL2MIXER_WAVPACK=OFF"
    "-DSDL2MIXER_SAMPLES=OFF"
  ];

  buildPhase = ''
    runHook preBuild

    cmake --build build -j$NIX_BUILD_CORES

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    DESTDIR="$out" cmake --install build

    runHook postInstall
  '';

  doCheck = false;

  meta = {
    description = "Audio mixer library for SDL2";
    homepage = "https://github.com/libsdl-org/SDL_mixer";
    license = lib.licenses.zlib;
    platforms = lib.platforms.all;
  };
}
