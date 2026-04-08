# pspdev-nix

Nix flake that provides a PSP development toolchain.

## Binary cache

This flake is built and cached on Cachix:

- Cache: `https://pspdev.cachix.org`
- Public key: `pspdev.cachix.org-1:lFw1M0EYJeN3Y2xHR7spiuPmThrNDXo8Z9I0Jgzig/0=`

To use it, add the following to your Nix configuration:

```nix
substituters = [ "https://pspdev.cachix.org" ];
trusted-public-keys = [ "pspdev.cachix.org-1:lFw1M0EYJeN3Y2xHR7spiuPmThrNDXo8Z9I0Jgzig/0=" ];
```

## Usage

In a `flake.nix` add the following:

```nix
{
  nixConfig = {
    extra-substituters = [ "https://pspdev.cachix.org" ];
    extra-trusted-public-keys = [ "pspdev.cachix.org-1:lFw1M0EYJeN3Y2xHR7spiuPmThrNDXo8Z9I0Jgzig/0=" ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    pspdev = {
      url = "github:slendidev/pspdev-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ nixpkgs, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = nixpkgs.lib.systems.flakeExposed;

      perSystem = { system, ... }: {
        devShells.default = inputs.pspdev.devShells.${system}.default;
      };
    };
}
```

You should then be able to run `nix develop`, or if you have
[nix-direnv](https://github.com/nix-community/nix-direnv) installed, add to
.envrc:

```
use flake
```

And you should be good to go!
