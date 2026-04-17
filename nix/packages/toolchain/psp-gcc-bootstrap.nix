{
  lib,
  fetchFromGitHub,
  stdenv,
  gmp,
  mpfr,
  libmpc,
  zlib,
  pkg-config,
  texinfo,
  which,
  perl,
  autoconf,
  bison,
  flex,
  m4,
  psp-binutils,
}:
let
  version = "allegrex-v15.2.0";
in
stdenv.mkDerivation rec {
  pname = "psp-gcc-bootstrap";
  inherit version;

  src = fetchFromGitHub {
    owner = "pspdev";
    repo = "gcc";
    rev = version;
    hash = "sha256-jvPJwApc7gQjtQQyjBq2lrLPmyfD+LdicIg7+MnNnTo=";
  };

  nativeBuildInputs = [
    pkg-config
    texinfo
    which
    perl
    autoconf
    bison
    flex
    m4
  ];

  buildInputs = [
    gmp
    mpfr
    libmpc
    zlib
    psp-binutils
  ];

  configureFlags = [
    "--target=psp"
    "--enable-languages=c"
    "--with-float=hard"
    "--with-headers=no"
    "--without-newlib"
    "--disable-libgcc"
    "--disable-shared"
    "--disable-threads"
    "--disable-libssp"
    "--disable-libgomp"
    "--disable-libmudflap"
    "--disable-libquadmath"
    "--disable-nls"
    "--with-gmp=${gmp.dev}"
    "--with-mpfr=${mpfr.dev}"
    "--with-mpc=${libmpc}"
    "--with-system-zlib"
  ];

  enableParallelBuilding = true;
  dontUpdateAutotoolsGnuConfigScripts = true;
  hardeningDisable = [
    "format"
    "stackclashprotection"
  ];

  postPatch = ''
    while IFS= read -r file; do
      substituteInPlace "$file" --replace-quiet 'rm -f conftest*' 'rm -fr conftest*'
    done < <(find . -type f \( -name configure -o -name "configure.*" -o -name "*.m4" \))
  '';

  configurePhase = ''
    export PATH=${psp-binutils}/bin:$PATH
    mkdir -p build-psp-stage1
    cd build-psp-stage1
    ../configure ${lib.escapeShellArgs configureFlags} --prefix=$out
  '';

  buildPhase = ''
    runHook preBuild
    make -j$NIX_BUILD_CORES all-gcc
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    make install-gcc
    runHook postInstall
  '';
}
