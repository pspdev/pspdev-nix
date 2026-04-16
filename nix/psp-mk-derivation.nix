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

      mkdir -p "$out"

      ebootPath=""
      for candidate in build/EBOOT.PBP EBOOT.PBP; do
        if [ -f "$candidate" ]; then
          ebootPath="$candidate"
          break
        fi
      done

      if [ -z "$ebootPath" ]; then
        echo "EBOOT.PBP not found in build/ or source root" >&2
        exit 1
      fi

      install -m644 "$ebootPath" "$out/EBOOT.PBP"

      ebootDir="$(dirname "$ebootPath")"
      for artifact in "$ebootDir"/*.prx; do
        if [ -f "$artifact" ]; then
          install -m644 "$artifact" "$out/$(basename "$artifact")"
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
