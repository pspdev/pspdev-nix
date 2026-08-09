{
  lib,
  fetchurl,
  pspMkLibraryDerivation,
}:

pspMkLibraryDerivation rec {
  pname = "psp-zlib";
  version = "1.3.2";
  src = fetchurl {
    url = "https://zlib.net/fossils/zlib-${version}.tar.gz";
    hash = "sha256-uzKaCizQJ00FUZ1hxmfAYuBpkNcuEl7i36jeZPARnRY=";
  };

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
    description = "General-purpose lossless data-compression library";
    homepage = "https://zlib.net/";
    license = lib.licenses.zlib;
    platforms = lib.platforms.all;
  };
}
