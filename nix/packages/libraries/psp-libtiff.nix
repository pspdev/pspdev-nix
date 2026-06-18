{
  lib,
  libtiff,
  psp-libjpeg,
  psp-zlib,
  pspMkLibraryDerivation,
}:

pspMkLibraryDerivation rec {
  pname = "psp-libtiff";
  inherit (libtiff) version src;

  buildSystem = "cmake";

  buildInputs = [
    psp-zlib
    psp-libjpeg
  ];

  cmakeFlags = [
    "-DCMAKE_INSTALL_PREFIX=/psp"
    "-DBUILD_SHARED_LIBS=OFF"
    "-Dtiff-static=ON"
    "-Dtiff-tools=OFF"
    "-Dtiff-tests=OFF"
    "-Dtiff-contrib=OFF"
    "-Dtiff-docs=OFF"
    "-Dtiff-deprecated=OFF"
    "-Dtiff-cxx=OFF"
    "-Dzlib=ON"
    "-Dlibdeflate=OFF"
    "-Djpeg=ON"
    "-Djpeg12=OFF"
    "-Djbig=OFF"
    "-Dlerc=OFF"
    "-Dlzma=OFF"
    "-Dzstd=OFF"
    "-Dwebp=OFF"
    "-Dtiff-opengl=OFF"
  ];

  doCheck = false;

  installPhase = ''
    runHook preInstall

    DESTDIR="$out" cmake --install build

    runHook postInstall
  '';

  meta = {
    inherit (libtiff.meta) description homepage license;
    platforms = lib.platforms.all;
  };
}
