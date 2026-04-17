{ callPackage }:
{
  psp-binutils-unwrapped = callPackage ./psp-binutils-unwrapped.nix { };
  psp-binutils = callPackage ./psp-binutils.nix { };
  psp-gcc-bootstrap = callPackage ./psp-gcc-bootstrap.nix { };
  psp-newlib = callPackage ./psp-newlib.nix { };
  psp-pthread-embedded = callPackage ./psp-pthread-embedded.nix { };
  pspsdk = callPackage ./pspsdk.nix { };
  psp-sysroot = callPackage ./psp-sysroot.nix { };
  psp-gcc-unwrapped = callPackage ./psp-gcc-unwrapped.nix { };
  psp-gcc = callPackage ./psp-gcc.nix { };
  psp-stdenv = callPackage ./psp-stdenv.nix { };
}
