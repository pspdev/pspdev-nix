{
  lib,
  libjpeg,
  pspMkLibraryDerivation,
}:

pspMkLibraryDerivation rec {
  pname = "psp-libjpeg";
  inherit (libjpeg) version src;

  buildSystem = "cmake";

  cmakeFlags = [
    "-DCMAKE_INSTALL_PREFIX=/psp"
    "-DBUILD_SHARED_LIBS=OFF"
    "-DENABLE_STATIC=ON"
    "-DENABLE_SHARED=OFF"
    "-DWITH_SIMD=OFF"
  ];

  doCheck = false;

  installPhase = ''
    runHook preInstall

    DESTDIR="$out" cmake --install build

    runHook postInstall
  '';

  meta = {
    inherit (libjpeg.meta) description homepage license;
    platforms = lib.platforms.all;
  };
}
