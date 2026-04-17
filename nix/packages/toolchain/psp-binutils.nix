{
  symlinkJoin,
  makeWrapper,
  psp-binutils-unwrapped,
}:
symlinkJoin {
  pname = "psp-binutils";
  version = psp-binutils-unwrapped.version;
  name = "psp-binutils-${psp-binutils-unwrapped.version}";
  paths = [ psp-binutils-unwrapped ];
  nativeBuildInputs = [ makeWrapper ];

  postBuild = ''
    if [ -x "$out/bin/psp-ld" ]; then
      wrapProgram "$out/bin/psp-ld" \
        --run 'if [ -n "''${NIXPSP_ADDITIONAL_SYSROOTS:-}" ]; then old_ifs=$IFS; IFS=:; for sysroot in $NIXPSP_ADDITIONAL_SYSROOTS; do [ -n "$sysroot" ] || continue; if [ -d "$sysroot/lib" ]; then set -- "$@" "-L$sysroot/lib"; fi; if [ -d "$sysroot/usr/lib" ]; then set -- "$@" "-L$sysroot/usr/lib"; fi; done; IFS=$old_ifs; fi'
    fi
  '';

  meta = psp-binutils-unwrapped.meta or { };
}
