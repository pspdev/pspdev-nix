{
  description = "PSPDEV";

  inputs = {
    nixpkgs.url     = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs@{ flake-parts, nixpkgs, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      perSystem = { pkgs, system, ... }:
        let
          my = import ./nix/packages {
            inherit pkgs;
          };
        in {
          packages = my // {
            default = pkgs.buildEnv {
              name = "pspdev";
              paths = [
                my.psp-binutils
                my.psp-gcc
                my.pspsdk
                my.psplink
                my.psplinkusb
                my.psp-pacman
                my.psp-pkg-config
                my.ebootsigner
                my.psp-cmake
              ];
            };
          };

          devShells.default = import ./nix/devshells.nix {
            inherit pkgs;
            packages = my;
          };
        };

      flake = {
        lib.pspMkDerivation = { pkgs }: pkgs.callPackage ./nix/psp-mk-derivation.nix { };
        overlays.default = import ./nix/overlays.nix;
      };
    };
}
