{
  lib,
  fetchFromGitHub,
  psp-pkg-config,
  psp-sdl3,
  pspMkLibraryDerivation,
}:

pspMkLibraryDerivation rec {
  pname = "psp-sdl3-net";
  version = "3.2.0";

  src = fetchFromGitHub {
    owner = "libsdl-org";
    repo = "SDL_net";
    tag = "release-${version}";
    hash = "sha256-PDnkVqFOMT79wC/hlxsIQRProhIRbAIXBF6hcNKmVbI=";
  };

  buildSystem = "cmake";

  nativeBuildInputs = [
    psp-pkg-config
  ];

  buildInputs = [
    psp-sdl3
  ];

  cmakeFlags = [
    "-DCMAKE_INSTALL_PREFIX=/psp"
    "-DSDL3_DIR=${psp-sdl3}/psp/lib/cmake/SDL3"
    "-DBUILD_SHARED_LIBS=OFF"
    (lib.cmakeBool "SDLNET_INSTALL" true)
    (lib.cmakeBool "SDLNET_SAMPLES" false)
    (lib.cmakeBool "SDLNET_SAMPLES_INSTALL" false)
    "-DSDLNET_STUB_ONLY=ON"
  ];

  doCheck = false;

  installPhase = ''
    runHook preInstall

    DESTDIR="$out" cmake --install build

    runHook postInstall
  '';

  meta = {
    description = "Portable network library for use with SDL";
    homepage = "https://github.com/libsdl-org/SDL_net";
    license = lib.licenses.zlib;
    platforms = lib.platforms.all;
  };
}
