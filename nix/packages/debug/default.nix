{ callPackage }:
{
  psplinkusb = callPackage ./psplinkusb.nix { };
  psplink = callPackage ./psplink.nix { };
}
