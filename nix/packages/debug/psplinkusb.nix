{
  fetchFromGitHub,
  stdenv,
  pkg-config,
  libusb1,
  readline,
}:
let
  version = "8cc9876a868d202c0ef4197395c5278aeeff2829";
in
stdenv.mkDerivation {
  pname = "psplinkusb";
  inherit version;

  src = fetchFromGitHub {
    owner = "pspdev";
    repo = "psplinkusb";
    rev = version;
    hash = "sha256-a8W87yodKOha3/vjJikAbaBXZWwQA9Z75XtcfKaI0A0=";
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
