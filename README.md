# pspdev-nix

Nix flake that provides a PSP development toolchain.

## Getting started

Make sure [flakes are enabled](https://nixos.wiki/wiki/Flakes). If you don't have Nix, [install it from here](https://github.com/DeterminateSystems/nix-installer). This installer can enable flakes for you.

Then create a new project using:

```sh
nix flake new --refresh --template github:pspdev/pspdev-nix#cmake project_dir
```

You can also initialize in the current directory with:

```sh
nix flake init --refresh --template github:pspdev/pspdev-nix#cmake
```

`--refresh` is specified as templates may change over time upstream, so this
way you will always make new projects using the latest templates.

## Binary cache

This flake is built and cached on Cachix:

- Cache: `https://pspdev.cachix.org`
- Public key: `pspdev.cachix.org-1:lFw1M0EYJeN3Y2xHR7spiuPmThrNDXo8Z9I0Jgzig/0=`

To use it, add the following to your Nix configuration:

```nix
substituters = [ "https://pspdev.cachix.org" ];
trusted-public-keys = [ "pspdev.cachix.org-1:lFw1M0EYJeN3Y2xHR7spiuPmThrNDXo8Z9I0Jgzig/0=" ];
```

## License

This project is licensed under the Apache License 2.0. See the
[LICENSE.txt](LICENSE.txt) file for more details.
