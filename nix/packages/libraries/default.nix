{ callPackage }:
{
  psp-zlib = callPackage ./psp-zlib.nix { };
  psp-libpng = callPackage ./psp-libpng.nix { };
  psp-lz4 = callPackage ./psp-lz4.nix { };
  psp-minilzo = callPackage ./psp-minilzo.nix { };
}
