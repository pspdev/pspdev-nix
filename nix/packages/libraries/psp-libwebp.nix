{
  lib,
  fetchurl,
  pspMkLibraryDerivation,
}:

pspMkLibraryDerivation rec {
  pname = "psp-libwebp";
  version = "1.6.0";
  src = fetchurl {
    url = "https://github.com/webmproject/libwebp/archive/v${version}.tar.gz";
    hash = "sha256-k6hSwrPvr+43I+/UY23oVbRvn+Hv3dYH4fQvYPyPITY=";
  };

  buildSystem = "cmake";

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail 'POSITION_INDEPENDENT_CODE ON)' 'POSITION_INDEPENDENT_CODE OFF)'
  '';

  cmakeFlags = [
    "-DCMAKE_INSTALL_PREFIX=/psp"
    "-DBUILD_SHARED_LIBS=OFF"
    "-DCMAKE_POSITION_INDEPENDENT_CODE=OFF"
    "-DWEBP_LINK_STATIC=OFF"
    "-DWEBP_ENABLE_SIMD=OFF"
    "-DWEBP_BUILD_ANIM_UTILS=OFF"
    "-DWEBP_BUILD_CWEBP=OFF"
    "-DWEBP_BUILD_DWEBP=OFF"
    "-DWEBP_BUILD_GIF2WEBP=OFF"
    "-DWEBP_BUILD_IMG2WEBP=OFF"
    "-DWEBP_BUILD_VWEBP=OFF"
    "-DWEBP_BUILD_WEBPINFO=OFF"
    "-DWEBP_BUILD_LIBWEBPMUX=ON"
    "-DWEBP_BUILD_WEBPMUX=OFF"
    "-DWEBP_BUILD_EXTRAS=OFF"
    "-DWEBP_USE_THREAD=OFF"
  ];

  doCheck = false;

  installPhase = ''
    runHook preInstall

    DESTDIR="$out" cmake --install build

    runHook postInstall
  '';

  meta = {
    description = "WebP image format library";
    homepage = "https://developers.google.com/speed/webp";
    license = lib.licenses.bsd3;
    platforms = lib.platforms.all;
  };
}
