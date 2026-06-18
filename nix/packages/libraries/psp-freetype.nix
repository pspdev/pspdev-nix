{
  lib,
  fetchurl,
  psp-libpng,
  psp-pkg-config,
  psp-zlib,
  pspMkLibraryDerivation,
}:

pspMkLibraryDerivation rec {
  pname = "psp-freetype";
  version = "2.11.0";

  src = fetchurl {
    url = "https://github.com/freetype/freetype/archive/VER-${
      builtins.replaceStrings [ "." ] [ "-" ] version
    }.tar.gz";
    hash = "sha256-//y6Jf69FYHMEtcGo5vulvN+q2J9CDjOboGJ69hB1yI=";
  };

  buildSystem = "cmake";

  nativeBuildInputs = [
    psp-pkg-config
  ];

  buildInputs = [
    psp-libpng
    psp-zlib
  ];

  cmakeFlags = [
    "-DCMAKE_INSTALL_PREFIX=/psp"
    "-DBUILD_SHARED_LIBS=OFF"
    "-DCMAKE_PREFIX_PATH=${psp-libpng}/psp;${psp-zlib}/psp"
    "-DCMAKE_POLICY_VERSION_MINIMUM=3.5"
    "-DFT_DISABLE_BZIP2=ON"
    "-DFT_DISABLE_BROTLI=ON"
    "-DFT_DISABLE_HARFBUZZ=ON"
  ];

  installPhase = ''
    runHook preInstall

    DESTDIR="$out" cmake --install build

    mkdir -p "$out/psp/lib/pkgconfig"

    cat > "$out/psp/lib/pkgconfig/freetype2.pc" <<'EOF'
    prefix=/psp
    exec_prefix=''${prefix}
    libdir=''${exec_prefix}/lib
    includedir=''${prefix}/include

    Name: FreeType 2
    Description: FreeType 2 font rendering library
    Version: ${version}
    Libs: -L''${libdir} -lfreetype
    Libs.private: -L${psp-libpng}/psp/lib -lpng -L${psp-zlib}/psp/lib -lz
    Cflags: -I''${includedir}
    EOF

    runHook postInstall
  '';

  doCheck = false;

  meta = {
    description = "PSP FreeType font rendering library";
    homepage = "https://www.freetype.org/";
    license = with lib.licenses; [
      ftl
      gpl2Plus
    ];
    platforms = lib.platforms.all;
  };
}
