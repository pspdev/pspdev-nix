{ callPackage }:
let
  fasterark = callPackage ./fasterark.nix { };
in
{
  psp-cfw-sdk = callPackage ./psp-cfw-sdk.nix { };
  psp-ark-5 = callPackage ./psp-ark-5.nix { };
  inherit fasterark;
  fasterark-psp-full = fasterark.full;
  fasterark-psp-lite = fasterark.lite;
  fasterark-themes = callPackage ./fasterark.nix { variant = "themes"; };
  ark-update = callPackage ./fasterark.nix { variant = "updater"; };
}
