{ pkgs }:
let
  callPackage = pkgs.lib.callPackageWith (
    pkgs
    // packages
    // {
      inherit pspMkDerivation pspMkLibraryDerivation;
    }
  );

  pspMkDerivation = callPackage ../psp-mk-derivation.nix { };
  pspMkLibraryDerivation = callPackage ../psp-mk-library-derivation.nix { };

  packages =
    import ./toolchain { inherit callPackage; }
  // import ./build-tools { inherit callPackage; }
  // import ./libraries { inherit callPackage; }
  // import ./debug { inherit callPackage; }
  // import ./custom-firmware { inherit callPackage; }
  // import ./homebrew { inherit callPackage; };
in
packages
