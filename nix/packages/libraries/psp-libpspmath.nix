{
  lib,
  fetchFromGitHub,
  pspMkLibraryDerivation,
}:
pspMkLibraryDerivation {
  pname = "psp-libpspmath";
  version = "r4.eb44107";

  src = fetchFromGitHub {
    owner = "tufty";
    repo = "libpspmath";
    rev = "eb44107538fa84bab299b5d7dcf71df64a674da3";
    hash = "sha256-F8cXaowraQLpJdTo8d0g0RSSkZTNU5xk4dVJ3oQscAk=";
  };

  installPhase = ''
    runHook preInstall
    install -Dm644 libpspmath.a "$out/psp/lib/libpspmath.a"
    install -Dm644 pspmath.h "$out/psp/include/pspmath.h"
    runHook postInstall
  '';

  meta = {
    description = "VFPU math library for PSP homebrew";
    homepage = "https://github.com/tufty/libpspmath";
    license = lib.licenses.bsd3;
    platforms = lib.platforms.all;
  };
}
