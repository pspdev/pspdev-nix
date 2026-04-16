{
  lib,
  stdenv,
  cmake,
  psp-cmake,
  psp-binutils,
  psp-gcc,
  pspsdk,
}:
args@{
  nativeBuildInputs ? [ ],
  buildInputs ? [ ],
  buildSystem ? null,
  cmakeDir ? ".",
  ...
}:
let
  useCmake =
    if buildSystem != null then
      buildSystem == "cmake"
    else
      builtins.elem cmake nativeBuildInputs
      || builtins.elem psp-cmake nativeBuildInputs
      || builtins.elem cmake buildInputs
      || builtins.elem psp-cmake buildInputs;

  commonEnv = {
    PSPDEV = "${pspsdk}";
    PSPSDK = "${pspsdk}/psp/sdk";
    PSPDIR = "${pspsdk}/psp/sdk";

    NIXPSP_ADDITIONAL_SYSROOTS = lib.makeSearchPath "psp" buildInputs;
  };

  commonNativeBuildInputs =
    [
      psp-binutils
      psp-gcc
      pspsdk
    ]
    ++ lib.optionals useCmake [
      psp-cmake
      cmake
    ];
in
stdenv.mkDerivation (
  args
  // {
    nativeBuildInputs = lib.unique (commonNativeBuildInputs ++ nativeBuildInputs);
    inherit buildInputs;

    dontConfigure = args.dontConfigure or (!useCmake);

    installPhase = args.installPhase or ''
      runHook preInstall

      mkdir -p "$out/psp/include" "$out/psp/lib" "$out/bin"

      for dir in include Includes; do
        if [ -d "$dir" ]; then
          cp -r "$dir"/. "$out/psp/include/"
        fi
      done

      for dir in libs lib build build/src build/lib; do
        if [ -d "$dir" ]; then
          find "$dir" -type f \( -name '*.a' -o -name '*.prx' \) \
            -exec install -m644 -t "$out/psp/lib" {} +
        fi
      done

      runHook postInstall
    '';

    env = (args.env or { }) // commonEnv;
  }
  // lib.optionalAttrs useCmake {
    configurePhase = args.configurePhase or ''
      runHook preConfigure
      ${psp-cmake}/bin/psp-cmake -S ${lib.escapeShellArg cmakeDir} -DCMAKE_BUILD_TYPE=Release -B build ''${cmakeFlags:+$cmakeFlags}
      runHook postConfigure
    '';

    buildPhase = args.buildPhase or ''
      runHook preBuild
      ${cmake}/bin/cmake --build build -j$NIX_BUILD_CORES
      runHook postBuild
    '';
  }
)
