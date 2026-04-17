{
  lib,
  zlib,
  pspMkLibraryDerivation,
}:

pspMkLibraryDerivation rec {
  pname = "psp-zlib";
  inherit (zlib) version src;

  buildSystem = "cmake";

  cmakeFlags = [
    "-DCMAKE_INSTALL_PREFIX=/psp"
    "-DCMAKE_BUILD_TYPE=Release"
    "-DBUILD_SHARED_LIBS=OFF"
    "-DZLIB_BUILD_SHARED=OFF"
    "-DZLIB_BUILD_STATIC=ON"
    "-DZLIB_BUILD_TESTING=OFF"
    "-DZLIB_BUILD_EXAMPLES=OFF"
    "-DUNIX=ON"
  ];

  installPhase = ''
    runHook preInstall

    DESTDIR="$out" cmake --install build

    mkdir -p "$out/psp/lib/pkgconfig"

    substituteInPlace "$out/psp/lib/pkgconfig/zlib.pc" \
      --replace 'prefix=/psp' "prefix=$out/psp" \
      --replace 'prefix=''${pcfiledir}/../..' "prefix=$out/psp" \
      --replace 'prefix=/usr/local' "prefix=$out/psp" \
      --replace 'prefix=/usr' "prefix=$out/psp"

    runHook postInstall
  '';

  meta = {
    inherit (zlib.meta) description hmoepage license platforms maintainers;
  };
}
