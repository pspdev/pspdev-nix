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
  version = "97025b3366c6431282b34a75e276566bd20ad905";
in
pspMkDerivation {
  pname = "psp-ark-5";
  inherit version;

  buildSystem = "cmake";

  src = fetchFromGitHub {
    owner = "PSP-Arkfive";
    repo = "ARK-5";
    rev = version;
    hash = "sha256-Sq9bhrJw6REyy4f+6wOOCf3EGsRmhmde1LfZYnvwJRg=";
  };

  nativeBuildInputs = [
    which
    python3
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
}
