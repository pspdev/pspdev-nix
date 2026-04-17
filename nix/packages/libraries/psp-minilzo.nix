{
  fetchFromGitHub,
  lib,
  pspMkLibraryDerivation,
}:

pspMkLibraryDerivation rec {
  pname = "psp-minilzo";
  version = "2.09";

  src = fetchFromGitHub {
    owner = "yuhaoth";
    repo = "minilzo";
    rev = "b088e80336ef11c5a29ec949a950d4f0fec9ec05";
    hash = "sha256-mUycaSSt+xIE4rS/tSh1xtqia21tAj4ixAx6Dbzzh10=";
  };

  buildSystem = "custom";

  buildPhase = ''
    runHook preBuild

    mkdir -p build/psp
    psp-gcc -c -o build/psp/minilzo.o minilzo.c
    psp-ar rcs build/psp/libminilzo.a build/psp/minilzo.o

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/psp/lib"
    install -m 644 build/psp/libminilzo.a "$out/psp/lib/"

    mkdir -p "$out/psp/include"
    install -m 644 *.h "$out/psp/include/"

    mkdir -p "$out/psp/share/licenses/minilzo"
    install -m 644 COPYING "$out/psp/share/licenses/minilzo/"

    runHook postInstall
  '';

  meta = {
    description = "Mini subset of the LZO real-time data compression library";
    homepage = "https://github.com/yuhaoth/minilzo";
    license = lib.licenses.gpl2Only;
    platforms = lib.platforms.all;
  };
}
