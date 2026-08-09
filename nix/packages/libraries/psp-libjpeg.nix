{
  lib,
  fetchurl,
  pspMkLibraryDerivation,
}:

pspMkLibraryDerivation rec {
  pname = "psp-libjpeg";
  version = "3.1.4.1";
  src = fetchurl {
    url = "https://github.com/libjpeg-turbo/libjpeg-turbo/archive/refs/tags/${version}.tar.gz";
    hash = "sha256-p9pCtkA3fCqalmXixLDqYM1Vma+0jCUh5t8MncnRWiU=";
  };

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
    description = "JPEG image codec library";
    homepage = "https://libjpeg-turbo.org/";
    license = lib.licenses.bsd3;
    platforms = lib.platforms.all;
  };
}
