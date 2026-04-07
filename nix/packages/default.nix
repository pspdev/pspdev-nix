{ pkgs }:
let
  packages = rec {
    pspMkDerivation = callPackage ../psp-mk-derivation.nix { };

    psp-binutils = callPackage ./psp-binutils.nix { };
    psp-gcc-bootstrap = callPackage ./psp-gcc-bootstrap.nix { };
    psp-newlib = callPackage ./psp-newlib.nix { };
    psp-pthread-embedded = callPackage ./psp-pthread-embedded.nix { };
    pspsdk = callPackage ./pspsdk.nix { };
    psp-sysroot = callPackage ./psp-sysroot.nix { };
    psp-gcc = callPackage ./psp-gcc.nix { };
    psp-stdenv = callPackage ./psp-stdenv.nix { };
    psplinkusb = callPackage ./psplinkusb.nix { };
    psplink = callPackage ./psplink.nix { };
    psp-pacman = callPackage ./psp-pacman.nix { };
    psp-pkg-config = callPackage ./psp-pkg-config.nix { };
    ebootsigner = callPackage ./ebootsigner.nix { };
    psp-cmake = callPackage ./psp-cmake.nix { };
  };

  callPackage = pkgs.lib.callPackageWith (pkgs // packages);
in
packages
