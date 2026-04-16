{
  fetchFromGitHub,
  pspMkDerivation,
  which,
  python3,
  gzip,
  psp-lz4,
  psp-minilzo,
  psp-cfw-sdk,
}:
let
  version = "9a24e2a322aa02259dfa37a32b2c5920e35efb06";
in
pspMkDerivation {
  pname = "psp-ark-5";
  inherit version;

  buildSystem = "cmake";

  src = fetchFromGitHub {
    owner = "PSP-Arkfive";
    repo = "ARK-5";
    rev = version;
    hash = "sha256-v0IPApVyl7Xk2XfR+Gg/2Xlh4wSXVCW694AhLb8Oqdo=";
  };

  nativeBuildInputs = [
    which
    python3
    gzip
  ];

  buildInputs = [
    psp-lz4
    psp-minilzo
    psp-cfw-sdk
  ];

  preConfigure = ''
    cp -r --no-preserve=mode,ownership ${psp-cfw-sdk.src} ./psp-cfw-sdk
    chmod -R u+w ./psp-cfw-sdk
  '';

  cmakeFlags = [
    "-DPSPCFWSDK_PATH=psp-cfw-sdk"
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p "$out"
    cp -rv dist/* $out/
    cp -rv Resources/ARK_01234 $out/

    runHook postInstall
  '';

  patches = [
    ./fixes.patch
  ];
}
