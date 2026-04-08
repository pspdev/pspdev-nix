{
  lib,
  fetchFromGitHub,
  binutils-unwrapped,
  stdenv,
  gmp,
  mpfr,
  zlib,
  pkg-config,
  texinfo,
  perl,
  autoconf,
  automake,
  libtool,
  bison,
  flex,
}:
let
  version = "allegrex-v2.44";
in
stdenv.mkDerivation rec {
  pname = "psp-binutils";
  inherit version;

  src = fetchFromGitHub {
    owner = "pspdev";
    repo = "binutils-gdb";
    rev = version;
    hash = "sha256-uUJS1USIsgbsmbkMOCF/+UqTWdXaLeAXF8lmFcI411w=";
  };

  patches = binutils-unwrapped.patches;

  nativeBuildInputs = [
    pkg-config
    texinfo
    perl
    autoconf
    automake
    libtool
    bison
    flex
  ];

  buildInputs = [
    gmp
    mpfr
    zlib
  ];

  preConfigure = lib.optionalString stdenv.hostPlatform.isLinux ''
    export CFLAGS="$CFLAGS -std=gnu17"
  '';

  configureFlags = [
    "--target=psp"
    "--enable-plugins"
    "--disable-initfini-array"
    "--with-python=no"
    "--disable-werror"
    "--with-system-zlib"
    "--with-sysroot=${placeholder "out"}/psp"
  ];

  enableParallelBuilding = true;
  dontUpdateAutotoolsGnuConfigScripts = true;

  postPatch = ''
    while IFS= read -r file; do
      substituteInPlace "$file" --replace-quiet 'rm -f conftest*' 'rm -fr conftest*'
    done < <(find . -type f \( -name configure -o -name "configure.*" -o -name "*.m4" \))
  '';

  configurePhase = ''
    runHook preConfigure
    mkdir -p build-psp
    cd build-psp
    ../configure ${lib.escapeShellArgs configureFlags} --prefix=$out
    runHook postConfigure
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
