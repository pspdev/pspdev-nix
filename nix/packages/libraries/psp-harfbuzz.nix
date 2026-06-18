{
  lib,
  fetchurl,
  psp-freetype,
  psp-pkg-config,
  pspMkLibraryDerivation,
}:

pspMkLibraryDerivation rec {
  pname = "psp-harfbuzz";
  version = "8.5.0";

  src = fetchurl {
    url = "https://github.com/harfbuzz/harfbuzz/releases/download/${version}/harfbuzz-${version}.tar.xz";
    hash = "sha256-d+T3+Y89hr+HiLU+aDL7lieZVuHDlhmI6j1LfKQd3Cc=";
  };

  buildSystem = "cmake";

  nativeBuildInputs = [
    psp-pkg-config
  ];

  buildInputs = [
    psp-freetype
  ];

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail '    list(APPEND THIRD_PARTY_LIBS Threads::Threads)' "" \
      --replace-fail 'if (UNIX OR MINGW OR VITA)' 'if (UNIX OR MINGW OR VITA OR PSP)'
  '';

  cmakeFlags = [
    "-DCMAKE_INSTALL_PREFIX=/psp"
    "-DBUILD_SHARED_LIBS=OFF"
    "-DCMAKE_PREFIX_PATH=${psp-freetype}/psp"
    "-DFREETYPE_LIBRARY=${psp-freetype}/psp/lib/libfreetype.a"
    "-DFREETYPE_INCLUDE_DIRS=${psp-freetype}/psp/include/freetype2"
    "-DHB_HAVE_FREETYPE=ON"
  ];

  installPhase = ''
        runHook preInstall

        mkdir -p "$out/psp/include/harfbuzz" "$out/psp/lib"
        mkdir -p "$out/psp/lib/pkgconfig"
        install -m644 build/libharfbuzz.a "$out/psp/lib/"
        install -m644 build/libharfbuzz-subset.a "$out/psp/lib/"

        for header in src/hb*.h src/hb*.hh; do
          install -Dm644 "$header" "$out/psp/include/harfbuzz/$(basename "$header")"
        done
        install -Dm644 build/src/hb-features.h "$out/psp/include/harfbuzz/hb-features.h"

        cat > "$out/psp/lib/pkgconfig/harfbuzz.pc" <<'EOF'
    prefix=/psp
    exec_prefix=''${prefix}
    libdir=''${exec_prefix}/lib
    includedir=''${prefix}/include/harfbuzz

    Name: HarfBuzz
    Description: OpenType text shaping engine
    Version: ${version}
    Requires.private: freetype2
    Libs: -L''${libdir} -lharfbuzz -L${psp-freetype}/psp/lib -lfreetype
    Cflags: -I''${includedir}
    EOF

        cat > "$out/psp/lib/pkgconfig/harfbuzz-subset.pc" <<'EOF'
    prefix=/psp
    exec_prefix=''${prefix}
    libdir=''${exec_prefix}/lib
    includedir=''${prefix}/include/harfbuzz

    Name: HarfBuzz Subset
    Description: HarfBuzz subset library
    Version: ${version}
    Requires.private: harfbuzz
    Libs: -L''${libdir} -lharfbuzz-subset
    Cflags: -I''${includedir}
    EOF

        runHook postInstall
  '';

  doCheck = false;

  meta = {
    description = "PSP OpenType text shaping engine";
    homepage = "https://harfbuzz.github.io/";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
}
