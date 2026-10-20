{
  lib,
  fetchFromGitHub,
  pspMkLibraryDerivation,
  psp-libpng,
  psp-libpspav,
  psp-zlib,
  psp-libpspmath,
  psp-libpspvram,
}:
pspMkLibraryDerivation {
  pname = "psp-ya2d";
  version = "unstable-2026-05-13";

  src = fetchFromGitHub {
    owner = "xerpi";
    repo = "ya2d";
    rev = "8f972b230cdebe6f6ab9480ec9ba5ecc51275352";
    hash = "sha256-spX+dkRx9FBCwp0QJ5SUgPSpV4Ar979pkzaJD5nOWz0=";
  };

  buildInputs = [
    psp-libpng
    psp-libpspav
    psp-zlib
    psp-libpspmath
    psp-libpspvram
  ];

  buildPhase = ''
    runHook preBuild
    make -C libya2d -j$NIX_BUILD_CORES
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -Dm644 libya2d/libya2d.a "$out/psp/lib/libya2d.a"
    mkdir -p "$out/psp/include"
    cp libya2d/*.h "$out/psp/include/"
    install -Dm644 LICENSE.txt "$out/share/licenses/ya2d/LICENSE.txt"
    runHook postInstall
  '';

  meta = {
    description = "Yet Another 2D library for PSP";
    homepage = "https://github.com/xerpi/ya2d";
    license = lib.licenses.lgpl21Plus;
    platforms = lib.platforms.all;
  };
}
