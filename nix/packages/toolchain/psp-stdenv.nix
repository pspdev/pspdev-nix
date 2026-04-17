{
  stdenv,
  overrideCC,
  symlinkJoin,
  makeWrapper,
  psp-gcc,
  psp-sysroot,
}:
let
  psp-gcc-wrapped = symlinkJoin {
    name = "psp-gcc-wrapped-${psp-gcc.version}";
    paths = [ psp-gcc ];
    nativeBuildInputs = [ makeWrapper ];
    postBuild = ''
      for driver in psp-gcc psp-g++ psp-c++ psp-cpp; do
        if [ -x "$out/bin/$driver" ]; then
          wrapProgram "$out/bin/$driver" --add-flags "--sysroot=${psp-sysroot}/psp"
        fi
      done
    '';
    meta = psp-gcc.meta or { };
  };
in
overrideCC stdenv psp-gcc-wrapped
