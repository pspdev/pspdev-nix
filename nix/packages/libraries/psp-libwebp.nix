{
  lib,
  libwebp,
  pspMkLibraryDerivation,
}:

pspMkLibraryDerivation rec {
  pname = "psp-libwebp";
  inherit (libwebp) version src;

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
    inherit (libwebp.meta) description homepage license;
    platforms = lib.platforms.all;
  };
}
