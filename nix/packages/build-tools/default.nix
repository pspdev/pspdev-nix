{ callPackage }:
{
  psp-pacman = callPackage ./psp-pacman.nix { };
  psp-pkg-config = callPackage ./psp-pkg-config.nix { };
  ebootsigner = callPackage ./ebootsigner.nix { };
  psp-cmake = callPackage ./psp-cmake.nix { };
  psp-clangd = callPackage ./psp-clangd.nix { };
}
