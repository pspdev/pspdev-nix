{
  lib,
  fetchFromGitHub,
  psp-pkg-config,
  psp-sdl3,
  pspMkLibraryDerivation,
}:

pspMkLibraryDerivation rec {
  pname = "psp-sdl3-mixer";
  version = "3.2.4";

  src = fetchFromGitHub {
    owner = "libsdl-org";
    repo = "SDL_mixer";
    tag = "release-${version}";
    hash = "sha256-mPk6xU1/GkBtWgF8S9ttha7/PNxcBEiSxpzo6ARLC9I=";
  };

  buildSystem = "cmake";

  nativeBuildInputs = [
    psp-pkg-config
  ];

  buildInputs = [ psp-sdl3 ];

  cmakeFlags = [
    "-DCMAKE_INSTALL_PREFIX=/psp"
    "-DSDL3_DIR=${psp-sdl3}/psp/lib/cmake/SDL3"
    "-DBUILD_SHARED_LIBS=OFF"
    "-DSDLMIXER_VENDORED=OFF"
    (lib.cmakeBool "SDLMIXER_INSTALL" true)
    (lib.cmakeBool "SDLMIXER_STRICT" true)
    (lib.cmakeBool "SDLMIXER_TESTS" false)
    (lib.cmakeBool "SDLMIXER_EXAMPLES" false)
    (lib.cmakeBool "SDLMIXER_FLAC" false)
    (lib.cmakeBool "SDLMIXER_MIDI" false)
    (lib.cmakeBool "SDLMIXER_OPUS" false)
    (lib.cmakeBool "SDLMIXER_GME" false)
    (lib.cmakeBool "SDLMIXER_MOD" false)
    (lib.cmakeBool "SDLMIXER_MOD_XMP" false)
    (lib.cmakeBool "SDLMIXER_MP3_DRMP3" true)
    (lib.cmakeBool "SDLMIXER_MP3_MPG123" false)
    (lib.cmakeBool "SDLMIXER_MIDI_FLUIDSYNTH" false)
    (lib.cmakeBool "SDLMIXER_MIDI_TIMIDITY" true)
    (lib.cmakeBool "SDLMIXER_VORBIS_VORBISFILE" false)
    (lib.cmakeBool "SDLMIXER_VORBIS_TREMOR" false)
    (lib.cmakeBool "SDLMIXER_VORBIS_STB" true)
    (lib.cmakeBool "SDLMIXER_WAVPACK" false)
  ];

  doCheck = false;

  installPhase = ''
    runHook preInstall

    DESTDIR="$out" cmake --install build

    runHook postInstall
  '';

  meta = {
    description = "SDL audio mixer library for SDL3";
    homepage = "https://github.com/libsdl-org/SDL_mixer";
    license = lib.licenses.zlib;
    platforms = lib.platforms.all;
  };
}
