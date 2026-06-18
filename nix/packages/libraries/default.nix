{ callPackage }:
{
  psp-zlib = callPackage ./psp-zlib.nix { };
  psp-libjpeg = callPackage ./psp-libjpeg.nix { };
  psp-libpspvram = callPackage ./psp-libpspvram.nix { };
  psp-libpng = callPackage ./psp-libpng.nix { };
  psp-freetype = callPackage ./psp-freetype.nix { };
  psp-harfbuzz = callPackage ./psp-harfbuzz.nix { };
  psp-libwebp = callPackage ./psp-libwebp.nix { };
  psp-libtiff = callPackage ./psp-libtiff.nix { };
  psp-lz4 = callPackage ./psp-lz4.nix { };
  psp-minilzo = callPackage ./psp-minilzo.nix { };
  psp-pspgl = callPackage ./psp-pspgl.nix { };
  psp-sdl2 = callPackage ./psp-sdl2.nix { };
  psp-sdl2-gfx = callPackage ./psp-sdl2-gfx.nix { };
  psp-sdl2-image = callPackage ./psp-sdl2-image.nix { };
  psp-sdl2-mixer = callPackage ./psp-sdl2-mixer.nix { };
  psp-sdl2-net = callPackage ./psp-sdl2-net.nix { };
  psp-sdl2-sound = callPackage ./psp-sdl2-sound.nix { };
  psp-sdl2-ttf = callPackage ./psp-sdl2-ttf.nix { };
  psp-sdl3 = callPackage ./psp-sdl3.nix { };
  psp-sdl3-image = callPackage ./psp-sdl3-image.nix { };
  psp-sdl3-mixer = callPackage ./psp-sdl3-mixer.nix { };
  psp-sdl3-net = callPackage ./psp-sdl3-net.nix { };
  psp-sdl3-ttf = callPackage ./psp-sdl3-ttf.nix { };
}
