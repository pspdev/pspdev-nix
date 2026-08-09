{
  lib,
  fetchurl,
  psp-zlib,
  pspMkLibraryDerivation,
}:

pspMkLibraryDerivation rec {
  pname = "psp-libpng";
  version = "1.6.58";
  src = fetchurl {
    url = "mirror://sourceforge/libpng/libpng-${version}.tar.xz";
    hash = "sha256-KOtAP1Hw90BSSRMs7P6C6lwO+X8bMsWmWCiBSuDTR3U=";
  };

  buildSystem = "cmake";

  buildInputs = [ psp-zlib ];

  patchPhase = ''
    runHook prePatch

    sed -i 's#@prefix@#''${PSPDEV}/psp#' libpng-config.in libpng.pc.in
    sed -i 's#@exec_prefix@#''${prefix}#' libpng-config.in libpng.pc.in
    sed -i 's#@libdir@#''${prefix}/lib#' libpng-config.in libpng.pc.in
    sed -i 's#@includedir@/libpng@PNGLIB_MAJOR@@PNGLIB_MINOR@#''${prefix}/include/libpng@PNGLIB_MAJOR@@PNGLIB_MINOR@#' \
      libpng-config.in libpng.pc.in

    runHook postPatch
  '';

  cmakeFlags = [
    "-DCMAKE_INSTALL_PREFIX=/psp"
    "-DCMAKE_BUILD_TYPE=Release"
    "-DBUILD_SHARED_LIBS=OFF"
    "-DPNG_SHARED=OFF"
    "-DPNG_STATIC=ON"
    "-DPNG_TESTS=OFF"
    "-DPNG_EXECUTABLES=OFF"
    "-DUNIX=ON"
    "-DZLIB_INCLUDE_DIR=${psp-zlib}/psp/include"
    "-DZLIB_LIBRARY=${psp-zlib}/psp/lib/libz.a"
  ];

  installPhase = ''
    runHook preInstall

    DESTDIR="$out" cmake --install build

    mkdir -p "$out/psp/lib/pkgconfig"

    substituteInPlace "$out/psp/lib/pkgconfig/libpng.pc" \
      --replace \''${PSPDEV}/psp "$out/psp"

    substituteInPlace "$out/psp/bin/libpng-config" \
      --replace \''${PSPDEV}/psp "$out/psp"

    runHook postInstall
  '';

  meta = {
    description = "Portable Network Graphics library";
    homepage = "https://libpng.sourceforge.net/";
    license = lib.licenses.libpng;
    platforms = lib.platforms.all;
  };
}
