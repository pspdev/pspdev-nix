{
  lib,
  fetchFromGitHub,
  lz4,
  pspMkLibraryDerivation,
}:

pspMkLibraryDerivation rec {
  pname = "psp-lz4";
  version = "1.9.4";

  src = fetchFromGitHub {
    owner = "lz4";
    repo = "lz4";
    rev = "v${version}";
    hash = "sha256-YiMCD3vvrG+oxBUghSrCmP2LAfAGZrEaKz0YoaQJhpI=";
  };

  buildSystem = "cmake";
  cmakeDir = "build/cmake";

  postPatch = ''
    sed -i "s#@PREFIX@#$out/psp#" lib/liblz4.pc.in
    rm -f programs/*.c
  '';

  cmakeFlags = [
    "-DCMAKE_INSTALL_PREFIX=/psp"
    "-DCMAKE_BUILD_TYPE=Release"
    "-DBUILD_SHARED_LIBS=OFF"
    "-DBUILD_STATIC_LIBS=ON"
    "-DLZ4_POSITION_INDEPENDENT_LIB=OFF"
    "-DLZ4_BUILD_CLI=OFF"
    "-DLZ4_BUILD_LEGACY_LZ4C=OFF"
    "-DCMAKE_POLICY_VERSION_MINIMUM=3.5"
  ];

  installPhase = ''
    runHook preInstall

    DESTDIR="$out" cmake --install build

    mkdir -p "$out/psp/share/licenses/lz4"
    install -m 644 LICENSE "$out/psp/share/licenses/lz4/"

    runHook postInstall
  '';

  meta = {
    inherit (lz4.meta) description homepage license;
    platforms = lib.platforms.all;
  };
}
