{
  fetchFromGitHub,
  stdenv,
  psp-binutils,
  psp-gcc-bootstrap,
  psp-newlib,
}:
let
  version = "platform_agnostic";
in
stdenv.mkDerivation rec {
  pname = "psp-pthread-embedded";
  inherit version;

  src = fetchFromGitHub {
    owner = "pspdev";
    repo = "pthread-embedded";
    rev = "97fe4ce006b420894f2bcaeb530d1f1f53111fc2"; # branch: platform_agnostic
    hash = "sha256-YAf62AMCinnqSGqI5PZ3nAVzQETuzBP85yRza09GR54=";
  };

  enableParallelBuilding = true;

  buildPhase = ''
    runHook preBuild

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

    export PATH=${psp-binutils}/bin:${psp-gcc-bootstrap}/bin:$PATH
    export PATH=$PWD/.toolwrap/bin:$PATH
    make -C platform/psp -j$NIX_BUILD_CORES all \
      PSPDEV=${psp-newlib} \
      GLOBAL_CFLAGS="--sysroot=${psp-newlib}/psp -isystem ${psp-newlib}/psp/include"
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    export PATH=${psp-binutils}/bin:${psp-gcc-bootstrap}/bin:$PATH
    make -C platform/psp install \
      DESTDIR=$out/psp \
      PSPDEV=${psp-newlib}
    runHook postInstall
  '';
}
