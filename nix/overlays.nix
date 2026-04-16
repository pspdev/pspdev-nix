final: prev:
let
  packages = import ./packages {
    pkgs = final;
  };
in
packages
// {
  pspMkLibraryDerivation = import ./psp-mk-library-derivation.nix {
    inherit (final)
      lib
      stdenv
      cmake
      psp-cmake
      psp-binutils
      psp-gcc
      pspsdk
      ;
  };

  pspMkDerivation = import ./psp-mk-derivation.nix {
    inherit (final)
      lib
      stdenv
      cmake
      psp-cmake
      psp-binutils
      psp-gcc
      pspsdk
      ;
  };

  pspMkShell = import ./psp-mk-shell.nix {
    inherit (final)
      lib
      mkShell
      cmake
      gnumake
      ninja
      psp-binutils
      psp-gcc
      pspsdk
      psp-cmake
      ;

    inherit (packages)
      psp-clangd
      psp-pacman
      psp-pkg-config
      psplink
      psplinkusb
      ebootsigner
      ;
  };
}
