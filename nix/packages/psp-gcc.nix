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
  makeWrapper,
  patchelf,
  psp-binutils,
  psp-sysroot,
}:
let
  version = "allegrex-v15.2.0";
  gccVersion = lib.removePrefix "allegrex-v" version;
in
stdenv.mkDerivation rec {
  pname = "psp-gcc";
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
    makeWrapper
    patchelf
  ];

  buildInputs = [
    gmp
    mpfr
    libmpc
    zlib
    psp-binutils
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
    export PATH=${psp-binutils}/bin:$PATH
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

    mkdir -p "$out/libexec/psp-toolwrap/bin"
    ln -sf ${psp-binutils}/bin/psp-as "$out/libexec/psp-toolwrap/bin/as"
    ln -sf ${psp-binutils}/bin/psp-ld "$out/libexec/psp-toolwrap/bin/ld"
    ln -sf ${psp-binutils}/bin/psp-ar "$out/libexec/psp-toolwrap/bin/ar"
    ln -sf ${psp-binutils}/bin/psp-nm "$out/libexec/psp-toolwrap/bin/nm"
    ln -sf ${psp-binutils}/bin/psp-ranlib "$out/libexec/psp-toolwrap/bin/ranlib"
    ln -sf ${psp-binutils}/bin/psp-strip "$out/libexec/psp-toolwrap/bin/strip"
    ln -sf ${psp-binutils}/bin/psp-objcopy "$out/libexec/psp-toolwrap/bin/objcopy"
    ln -sf ${psp-binutils}/bin/psp-objdump "$out/libexec/psp-toolwrap/bin/objdump"
    ln -sf ${psp-binutils}/bin/psp-readelf "$out/libexec/psp-toolwrap/bin/readelf"

    for driver in psp-gcc psp-g++ psp-c++ psp-cpp; do
      if [ -x "$out/bin/$driver" ]; then
        wrapProgram "$out/bin/$driver" \
          --prefix PATH : "$out/libexec/psp-toolwrap/bin" \
          --add-flags "--sysroot=${psp-sysroot}/psp" \
          --add-flags "-isystem \$HOME/.local/share/pspdev/psp/include" \
          --add-flags "-L\$HOME/.local/share/pspdev/psp/lib"
      fi
    done

    runHook postInstall
  '';

  # Run after fixup/strip to avoid ending up with a stale archive index.
  postFixup = ''
    libgcc="$out/lib/gcc/psp/${gccVersion}/libgcc.a"
    if [ -f "$libgcc" ]; then
      chmod u+w "$libgcc"
      ${psp-binutils}/bin/psp-ranlib -D "$libgcc"
      chmod u-w "$libgcc"
    fi
  '';
}
