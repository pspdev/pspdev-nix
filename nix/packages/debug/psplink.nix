{
  fetchFromGitHub,
  pspMkDerivation,
}:
let
  version = "4b767c097e1f269b580758a7de0e386f5ad9a247";
in
pspMkDerivation {
  pname = "psplink";
  inherit version;

  src = fetchFromGitHub {
    owner = "pspdev";
    repo = "psplinkusb";
    rev = version;
    hash = "sha256-u6kaAuuuXK9jNEpv2r5bXm6Su4+XBL/8oDoLIF3lRAA=";
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
