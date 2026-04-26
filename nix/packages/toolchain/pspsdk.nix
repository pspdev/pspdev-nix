{
  fetchFromGitHub,
  stdenv,
  autoconf,
  automake,
  libtool,
  m4,
  pkg-config,
  perl,
  zlib,
  psp-binutils,
  psp-gcc-bootstrap,
  psp-newlib,
  psp-pthread-embedded,
}:
let
  version = "18ba1ccb411f509e472adee94ad5d19af56dd251";
in
stdenv.mkDerivation rec {
  pname = "pspsdk";
  inherit version;

  src = fetchFromGitHub {
    owner = "pspdev";
    repo = "pspsdk";
    rev = version;
    hash = "sha256-N3OrHJLlVr6iAC1Fsb9qDyekPGCyRPJvfaPw6zID27o=";
  };

  nativeBuildInputs = [
    autoconf
    automake
    libtool
    m4
    pkg-config
    perl
  ];

  buildInputs = [
    zlib
    psp-binutils
    psp-gcc-bootstrap
    psp-newlib
    psp-pthread-embedded
  ];

  dontUpdateAutotoolsGnuConfigScripts = true;

  postPatch = ''
    while IFS= read -r file; do
      substituteInPlace "$file" --replace-quiet 'rm -f conftest*' 'rm -fr conftest*'
    done < <(find . -type f \( -name configure -o -name "configure.*" -o -name "*.m4" \))

    perl -0pi -e 's|#include <pspsdk.h>|#include <pspsdk.h>\n#include <time.h>\n#ifndef SEM_VALUE_MAX\n#define SEM_VALUE_MAX 255\n#endif|' src/libpthreadglue/osal.c
  '';

  configurePhase = ''
    runHook preConfigure

    ./bootstrap
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

    cat > .toolwrap/bin/psp-gcc <<EOF
    #!${stdenv.shell}
    exec ${psp-gcc-bootstrap}/bin/psp-gcc --sysroot=${psp-newlib}/psp -isystem ${psp-newlib}/psp/include -isystem ${psp-pthread-embedded}/psp/include "\$@"
    EOF
    chmod +x .toolwrap/bin/psp-gcc

    cat > .toolwrap/bin/psp-g++ <<EOF
    #!${stdenv.shell}
    exec ${psp-gcc-bootstrap}/bin/psp-gcc --sysroot=${psp-newlib}/psp -isystem ${psp-newlib}/psp/include -isystem ${psp-pthread-embedded}/psp/include "\$@"
    EOF
    chmod +x .toolwrap/bin/psp-g++

    cat > .toolwrap/bin/psp-c++ <<EOF
    #!${stdenv.shell}
    exec ${psp-gcc-bootstrap}/bin/psp-gcc --sysroot=${psp-newlib}/psp -isystem ${psp-newlib}/psp/include -isystem ${psp-pthread-embedded}/psp/include "\$@"
    EOF
    chmod +x .toolwrap/bin/psp-c++

    export PSPDEV=$out
    export PATH=$PWD/.toolwrap/bin:${psp-binutils}/bin:${psp-gcc-bootstrap}/bin:$PATH
    ./configure --with-pspdev=$out

    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild
    export PATH=$PWD/.toolwrap/bin:${psp-binutils}/bin:${psp-gcc-bootstrap}/bin:$PATH
    make -j$NIX_BUILD_CORES
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    export PATH=$PWD/.toolwrap/bin:${psp-binutils}/bin:${psp-gcc-bootstrap}/bin:$PATH
    make install

    mkdir -p "$out/bin"
    for tool in strip objcopy ld as ar nm ranlib readelf; do
      ln -sf "${psp-binutils}/bin/psp-$tool" "$out/bin/psp-$tool"
    done

    cat >> "$out/psp/sdk/lib/build.mak" <<'EOF'
    CFLAGS += -I$(HOME)/.local/share/pspdev/psp/include -L$(HOME)/.local/share/pspdev/psp/lib
    EOF

    cat > .libgcc-compat.c <<'EOF'
    typedef unsigned int su_int;
    typedef unsigned long long du_int;

    static du_int udivmoddi4(du_int n, du_int d, du_int *rp) {
      du_int q = 0;
      du_int r = 0;
      int i;

      if (d == 0) {
        return 0;
      }

      for (i = 63; i >= 0; i--) {
        r = (r << 1) | ((n >> i) & 1u);
        if (r >= d) {
          r -= d;
          q |= ((du_int)1 << i);
        }
      }

      if (rp != 0) {
        *rp = r;
      }
      return q;
    }

    du_int __udivdi3(du_int a, du_int b) {
      return udivmoddi4(a, b, 0);
    }

    du_int __umoddi3(du_int a, du_int b) {
      du_int r;
      udivmoddi4(a, b, &r);
      return r;
    }
    EOF

    psp-gcc -c .libgcc-compat.c -o .libgcc-compat.o
    psp-ar r "$out/psp/sdk/lib/libcglue.a" .libgcc-compat.o
    psp-ranlib "$out/psp/sdk/lib/libcglue.a"
    runHook postInstall
  '';
}
