{ pkgs, packages }:
pkgs.mkShell {
  packages = [
    packages.psp-binutils
    packages.psp-gcc
    packages.pspsdk
    packages.psplink
    packages.psplinkusb
    packages.psp-pacman
    packages.psp-pkg-config
    packages.ebootsigner
    packages.psp-cmake
    packages.psp-clangd
    pkgs.gnumake
  ];
}
