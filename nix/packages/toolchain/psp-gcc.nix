{
  symlinkJoin,
  makeWrapper,
  psp-binutils,
  psp-gcc-unwrapped,
  psp-sysroot,
}:
symlinkJoin {
  pname = "psp-gcc";
  version = psp-gcc-unwrapped.version;
  name = "psp-gcc-${psp-gcc-unwrapped.version}";
  paths = [ psp-gcc-unwrapped ];
  nativeBuildInputs = [ makeWrapper ];

  postBuild = ''
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
          --run 'if [ -n "''${NIXPSP_ADDITIONAL_SYSROOTS:-}" ]; then old_ifs=$IFS; IFS=:; for sysroot in $NIXPSP_ADDITIONAL_SYSROOTS; do [ -n "$sysroot" ] || continue; if [ -d "$sysroot/include" ]; then set -- "$@" -isystem "$sysroot/include"; fi; if [ -d "$sysroot/usr/include" ]; then set -- "$@" -isystem "$sysroot/usr/include"; fi; if [ -d "$sysroot/lib" ]; then set -- "$@" "-L$sysroot/lib"; fi; if [ -d "$sysroot/usr/lib" ]; then set -- "$@" "-L$sysroot/usr/lib"; fi; done; IFS=$old_ifs; fi'
      fi
    done

    for tool in psp-gcc-ar psp-gcc-nm psp-gcc-ranlib; do
      if [ -x "$out/bin/$tool" ]; then
        wrapProgram "$out/bin/$tool" \
          --prefix PATH : "$out/libexec/psp-toolwrap/bin"
      fi
    done
  '';

  meta = psp-gcc-unwrapped.meta or { };
}
