{
  lib,
  mkShell,
  cmake,
  gnumake,
  ninja,
  psp-binutils,
  psp-gcc,
  pspsdk,
  psp-cmake,
  psp-clangd ? null,
  psp-pacman ? null,
  psp-pkg-config ? null,
  psplink ? null,
  psplinkusb ? null,
  ebootsigner ? null,
}:
{
  packages ? [ ],
  psp-packages ? [ ],
  useCmake ? true,
  includeTools ? true,
  ...
} @ args:

let
  sysrootPackages = [
    psp-binutils
    psp-gcc
    pspsdk
  ] ++ lib.optionals useCmake [ psp-cmake ]
    ++ psp-packages;

  toolPackages =
    lib.optionals useCmake [ cmake ]
    ++ lib.optionals includeTools (
      [ gnumake ninja ]
      ++ lib.optionals (psplink != null) [ psplink ]
      ++ lib.optionals (psplinkusb != null) [ psplinkusb ]
      ++ lib.optionals (psp-pacman != null) [ psp-pacman ]
      ++ lib.optionals (psp-pkg-config != null) [ psp-pkg-config ]
      ++ lib.optionals (ebootsigner != null) [ ebootsigner ]
      ++ lib.optionals (psp-clangd != null) [ psp-clangd ]
    );

  allPackages = sysrootPackages ++ toolPackages ++ packages;
in
mkShell (
  args
  // {
    packages = allPackages;

    PSPDEV = "${pspsdk}";
    PSPSDK = "${pspsdk}/psp/sdk";
    PSPDIR = "${pspsdk}/psp/sdk";

    NIXPSP_ADDITIONAL_SYSROOTS =
      lib.makeSearchPath "psp" sysrootPackages;
  }
)
