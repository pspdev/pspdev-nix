{
  fetchFromGitHub,
  stdenv,
}:
let
  version = "17d6386f034ac922f540ca78200961761b23ecae";
in
stdenv.mkDerivation {
  pname = "ebootsigner";
  inherit version;

  src = fetchFromGitHub {
    owner = "pspdev";
    repo = "ebootsigner";
    rev = version;
    hash = "sha256-Zcuy5wxHURtXm8D8gLX+MhhKaUwS4QD/HYLAD5vgEp0=";
  };

  buildPhase = ''
    runHook preBuild
    make
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/bin"
    install -m755 ebootsign "$out/bin/ebootsign"
    runHook postInstall
  '';
}
