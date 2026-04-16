{
  description = "PSPDEV";

  inputs = {
    nixpkgs.url     = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs@{ flake-parts, nixpkgs, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = nixpkgs.lib.systems.flakeExposed;

      perSystem = { pkgs, system, ... }:
        let
          my = import ./nix/packages {
            inherit pkgs;
          };
          allDerivations = pkgs.lib.attrValues (pkgs.lib.filterAttrs (_: pkg: pkgs.lib.isDerivation pkg) my);
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
                my.psp-clangd
              ];
            };
          };

          checks.build = pkgs.linkFarmFromDrvs "pspdev-all-packages" allDerivations;
        };

      flake = {
        lib = {
          pspMkDerivation = { pkgs }: pkgs.callPackage ./nix/psp-mk-derivation.nix { };
          pspMkLibraryDerivation = { pkgs }: pkgs.callPackage ./nix/psp-mk-library-derivation.nix { };
          pspMkShell = { pkgs }: pkgs.callPackage ./nix/psp-mk-shell.nix { };
        };
        overlays.default = import ./nix/overlays.nix;
        templates = {
          make = {
            path = ./src/templates/make;
            description = "PSP hello world template using Make";
          };
          cmake = {
            path = ./src/templates/cmake;
            description = "PSP hello world template using CMake";
          };
          sdl2 = {
            path = ./src/templates/sdl2;
            description = "PSP SDL2 template using CMake";
          };
        };
      };
    };
}
