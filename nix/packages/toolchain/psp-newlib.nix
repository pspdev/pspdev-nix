{
  lib,
  fetchFromGitHub,
  stdenv,
  texinfo,
  psp-binutils,
  psp-gcc-bootstrap,
}:
let
  version = "allegrex-v4.5.0";
in
stdenv.mkDerivation rec {
  pname = "psp-newlib";
  inherit version;

  src = fetchFromGitHub {
    owner = "pspdev";
    repo = "newlib";
    rev = version;
    hash = "sha256-i5dIZdDX4Q91uflpTkfTWvGMsCWVl04FVG319hyYxn4=";
  };

  nativeBuildInputs = [
    texinfo
  ];

  enableParallelBuilding = true;
  dontUpdateAutotoolsGnuConfigScripts = true;

  postPatch = ''
    while IFS= read -r file; do
      substituteInPlace "$file" --replace-quiet 'rm -f conftest*' 'rm -fr conftest*'
    done < <(find . -type f \( -name configure -o -name "configure.*" -o -name "*.m4" \))
  '';

  configureFlags = [
    "--target=psp"
    "--with-sysroot=${placeholder "out"}/psp"
    "--enable-newlib-retargetable-locking"
    "--enable-newlib-multithread"
    "--enable-newlib-io-c99-formats"
    "--enable-newlib-iconv"
    "--enable-newlib-iconv-encodings=us_ascii,utf8,utf16,ucs_2_internal,ucs_4_internal,iso_8859_1"
  ];

  configurePhase = ''
    export PATH=${psp-binutils}/bin:${psp-gcc-bootstrap}/bin:$PATH
    export NIX_CFLAGS_COMPILE="''${NIX_CFLAGS_COMPILE:-} -Wno-error"

    mkdir -p .toolwrap/bin
    ln -sf ${psp-binutils}/bin/psp-as .toolwrap/bin/as
    ln -sf ${psp-binutils}/bin/psp-ld .toolwrap/bin/ld
    ln -sf ${psp-binutils}/bin/psp-ar .toolwrap/bin/ar
    ln -sf ${psp-binutils}/bin/psp-nm .toolwrap/bin/nm
    ln -sf ${psp-binutils}/bin/psp-ranlib .toolwrap/bin/ranlib
    ln -sf ${psp-binutils}/bin/psp-strip .toolwrap/bin/strip
    ln -sf ${psp-binutils}/bin/psp-objcopy .toolwrap/bin/objcopy
    ln -sf ${psp-binutils}/bin/psp-objdump .toolwrap/bin/objdump
    ln -sf ${psp-binutils}/bin/psp-readelf .toolwrap/bin/readelf
    export PATH=$PWD/.toolwrap/bin:$PATH

    mkdir -p build-psp
    cd build-psp
    ../configure ${lib.escapeShellArgs configureFlags} --prefix=$out
  '';

  buildPhase = ''
    runHook preBuild
    make -j$NIX_BUILD_CORES all
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    make install
    runHook postInstall
  '';
}
