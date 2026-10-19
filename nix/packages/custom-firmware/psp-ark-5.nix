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
  version = "69fe3d898a87d3f100ddc5a51d7738bad200d162";
in
pspMkDerivation {
  pname = "psp-ark-5";
  inherit version;

  buildSystem = "cmake";

  src = fetchFromGitHub {
    owner = "PSP-Arkfive";
    repo = "ARK-5";
    rev = version;
    hash = "sha256-dsdnLeF61UE9Y+2+N+z7OpqspOOX2jb9eNw1oFLvHJY=";
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

    runHook postInstall
  '';
}
