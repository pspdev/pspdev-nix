{
  lib,
  fetchurl,
  psp-libjpeg,
  psp-zlib,
  pspMkLibraryDerivation,
}:

pspMkLibraryDerivation rec {
  pname = "psp-libtiff";
  version = "4.7.1";
  src = fetchurl {
    url = "https://gitlab.com/api/v4/projects/libtiff%2Flibtiff/repository/archive.tar.gz?sha=v${version}";
    hash = "sha256-NHLHWnEh0keL5m9qOi2NbGEfnD+b+KRVRET8KDTG7eU=";
  };

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
    description = "TIFF image library";
    homepage = "https://libtiff.gitlab.io/libtiff/";
    license = lib.licenses.libtiff;
    platforms = lib.platforms.all;
  };
}
