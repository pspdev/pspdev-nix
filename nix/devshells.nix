{ pkgs, packages }:
(pkgs.callPackage ./psp-mk-shell.nix {
  inherit (packages)
    psp-binutils
    psp-gcc
    pspsdk
    psp-cmake
    psp-clangd
    psp-pacman
    psp-pkg-config
    psplink
    psplinkusb
    ebootsigner;
}) { }
