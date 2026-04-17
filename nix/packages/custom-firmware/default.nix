{ callPackage }:
{
  psp-cfw-sdk = callPackage ./psp-cfw-sdk.nix { };
  psp-ark-5 = callPackage ./psp-ark-5.nix { };
}
