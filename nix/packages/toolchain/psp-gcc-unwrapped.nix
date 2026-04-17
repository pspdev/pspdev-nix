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
  patchelf,
  psp-binutils-unwrapped,
  psp-sysroot,
}:
let
  version = "allegrex-v15.2.0";
  gccVersion = lib.removePrefix "allegrex-v" version;
in
stdenv.mkDerivation rec {
  pname = "psp-gcc-unwrapped";
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
    patchelf
  ];

  buildInputs = [
    gmp
    mpfr
    libmpc
    zlib
    psp-binutils-unwrapped
    psp-sysroot
  ];

  configureFlags = [
    "--target=psp"
    "--with-sysroot=${psp-sysroot}/psp"
    "--with-native-system-header-dir=/include"
    "--enable-languages=c,c++"
    "--with-float=hard"
    "--with-newlib"
    "--disable-libssp"
    "--disable-libgcc-visibility"
    "--disable-multilib"
    "--enable-threads=posix"
    "--disable-tls"
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
    export PATH=${psp-binutils-unwrapped}/bin:$PATH
    mkdir -p build-psp-stage2
    cd build-psp-stage2
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

  postFixup = ''
    libgcc="$out/lib/gcc/psp/${gccVersion}/libgcc.a"
    if [ -f "$libgcc" ]; then
      chmod u+w "$libgcc"
      ${psp-binutils-unwrapped}/bin/psp-ranlib -D "$libgcc"
      chmod u-w "$libgcc"
    fi
  '';
}
