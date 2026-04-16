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
  useCmake ? true,
  includeTools ? true,
  ...
} @ args:

let
  basePackages = [
    psp-binutils
    psp-gcc
    pspsdk
  ];

  cmakePackages =
    lib.optionals useCmake [
      psp-cmake
      cmake
    ];

  toolPackages =
    lib.optionals includeTools (
      [
        gnumake
        ninja
      ]
      ++ lib.optionals (psplink != null) [ psplink ]
      ++ lib.optionals (psplinkusb != null) [ psplinkusb ]
      ++ lib.optionals (psp-pacman != null) [ psp-pacman ]
      ++ lib.optionals (psp-pkg-config != null) [ psp-pkg-config ]
      ++ lib.optionals (ebootsigner != null) [ ebootsigner ]
      ++ lib.optionals (psp-clangd != null) [ psp-clangd ]
    );

  allPackages =
    basePackages
    ++ cmakePackages
    ++ toolPackages
    ++ packages;
in
mkShell (
  args
  // {
    packages = allPackages;

    PSPDEV = "${pspsdk}";
    PSPSDK = "${pspsdk}/psp/sdk";
    PSPDIR = "${pspsdk}/psp/sdk";

    NIXPSP_ADDITIONAL_SYSROOTS =
      lib.makeSearchPath "psp" allPackages;
  }
)
