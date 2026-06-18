{
  lib,
  SDL2_sound,
  psp-sdl2,
  pspMkLibraryDerivation,
}:

pspMkLibraryDerivation rec {
  pname = "psp-sdl2-sound";
  inherit (SDL2_sound) version src;

  buildSystem = "cmake";

  buildInputs = [ psp-sdl2 ];

  postPatch = ''
    substituteInPlace src/SDL_sound_shn.c \
      --replace-fail '(int *) SDL_malloc((Uint32) (shn->maxnlpc * sizeof (Sint32)))' '(Sint32 *) SDL_malloc((Uint32) (shn->maxnlpc * sizeof (Sint32)))'
  '';

  cmakeFlags = [
    "-DCMAKE_INSTALL_PREFIX=/psp"
    "-DSDL2_DIR=${psp-sdl2}/psp/lib/cmake/SDL2"
    "-DCMAKE_PREFIX_PATH=${psp-sdl2}/psp"
    "-DBUILD_SHARED_LIBS=OFF"
    "-DSDLSOUND_DECODER_FLAC=OFF"
    "-DSDLSOUND_DECODER_VORBIS=OFF"
    "-DSDLSOUND_DECODER_MODPLUG=OFF"
    "-DSDLSOUND_DECODER_MP3=OFF"
    "-DSDLSOUND_DECODER_MIDI=OFF"
    "-DSDLSOUND_BUILD_SHARED=OFF"
    "-DSDLSOUND_BUILD_STATIC=ON"
    "-DSDLSOUND_BUILD_TEST=OFF"
    "-DSDLSOUND_BUILD_DOCS=OFF"
  ];

  doCheck = false;

  installPhase = ''
    runHook preInstall

    DESTDIR="$out" cmake --install build

    runHook postInstall
  '';

  meta = {
    inherit (SDL2_sound.meta) description homepage license;
    platforms = lib.platforms.all;
  };
}
