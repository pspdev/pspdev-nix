{
  lib,
  fetchurl,
  psp-sdl2,
  pspMkLibraryDerivation,
}:

pspMkLibraryDerivation rec {
  pname = "psp-sdl2-sound";
  version = "2.0.6";
  src = fetchurl {
    url = "https://github.com/icculus/SDL_sound/archive/v${version}.tar.gz";
    hash = "sha256-Y75XzIC80pru1sKXAHWYccRMkCUadQi40OrNjZzs4ww=";
  };

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
    description = "Sound decoding library for SDL2";
    homepage = "https://github.com/icculus/SDL_sound";
    license = lib.licenses.zlib;
    platforms = lib.platforms.all;
  };
}
