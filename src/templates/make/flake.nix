{
  nixConfig = {
    extra-substituters = [ "https://pspdev.cachix.org" ];
    extra-trusted-public-keys = [ "pspdev.cachix.org-1:lFw1M0EYJeN3Y2xHR7spiuPmThrNDXo8Z9I0Jgzig/0=" ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    pspdev = {
      url = "github:pspdev/pspdev-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ nixpkgs, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = nixpkgs.lib.systems.flakeExposed;

      perSystem = { system, ... }:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [ inputs.pspdev.overlays.default ];
          };
        in
        {
          packages.default = pkgs.pspMkDerivation {
            pname = "hello";
            version = "0.1.0";
            src = ./.;
          };

          devShells.default = inputs.pspdev.lib.pspMkShell { inherit pkgs; } {
            useCmake = false;
          };
        };
    };
}
