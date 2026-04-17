{
  fetchFromGitHub,
  pspMkDerivation,
}:
let
  version = "8cc9876a868d202c0ef4197395c5278aeeff2829";
in
pspMkDerivation {
  pname = "psplink";
  inherit version;

  src = fetchFromGitHub {
    owner = "pspdev";
    repo = "psplinkusb";
    rev = version;
    hash = "sha256-a8W87yodKOha3/vjJikAbaBXZWwQA9Z75XtcfKaI0A0=";
  };

  buildPhase = ''
    runHook preBuild
    make -C libpsplink all
    make -C libpsplink_driver all
    make -C libusbhostfs all
    make -C libusbhostfs_driver all
    make -C psplink all PSP_FW_VERSION=271
    make -C psplink_user all PSP_FW_VERSION=271
    make -C usbhostfs all PSP_FW_VERSION=271
    make -C usbgdb all PSP_FW_VERSION=271
    make -f Makefile.tools all

    cp bootstrap/psplink.png .
    mksfoex -d MEMSIZE=1 'PSPLink v3.2.1' PARAM.SFO
    pack-pbp EBOOT.PBP PARAM.SFO psplink.png NULL NULL NULL NULL psplink/psplink.prx NULL

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out"
    install -m644 psplink/psplink.prx "$out/psplink.prx"
    install -m644 psplink/psplink.ini "$out/psplink.ini"
    install -m644 psplink_user/psplink_user.prx "$out/psplink_user.prx"
    install -m644 usbhostfs/usbhostfs.prx "$out/usbhostfs.prx"
    install -m644 usbgdb/usbgdb.prx "$out/usbgdb.prx"
    install -m644 EBOOT.PBP "$out/EBOOT.PBP"

    for tool in debugmenu remotejoy scrkprintf siokprintf usbkprintf; do
      if [ -f "tools/$tool/$tool.prx" ]; then
        install -m644 "tools/$tool/$tool.prx" "$out/$tool.prx"
      fi
    done

    runHook postInstall
  '';
}
