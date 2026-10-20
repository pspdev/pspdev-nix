{
  fetchFromGitHub,
  stdenv,
  pkg-config,
  libusb1,
  readline,
}:
let
  version = "4b767c097e1f269b580758a7de0e386f5ad9a247";
in
stdenv.mkDerivation {
  pname = "psplinkusb";
  inherit version;

  src = fetchFromGitHub {
    owner = "pspdev";
    repo = "psplinkusb";
    rev = version;
    hash = "sha256-u6kaAuuuXK9jNEpv2r5bXm6Su4+XBL/8oDoLIF3lRAA=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    libusb1
    readline
  ];

  buildPhase = ''
    runHook preBuild
    make -C pspsh all
    make -C usbhostfs_pc all
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/bin"
    install -m755 pspsh/pspsh "$out/bin/pspsh"
    install -m755 usbhostfs_pc/usbhostfs_pc "$out/bin/usbhostfs_pc"
    runHook postInstall
  '';
}
