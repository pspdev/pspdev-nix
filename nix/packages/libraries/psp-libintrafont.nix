{
  lib,
  fetchFromGitHub,
  pspMkLibraryDerivation,
}:
pspMkLibraryDerivation {
  pname = "psp-libintrafont";
  version = "4.1";

  src = fetchFromGitHub {
    owner = "pspdev";
    repo = "libintrafont";
    rev = "fd8aabd12dacbfe7b42a387e5beeb1c2a738ba26";
    hash = "sha256-ntxWe3KSpmTm5S02MxwKrYvYIdWWqyWoHRJyzLEZK4A=";
  };

  makeFlags = [
    "-f"
    "Makefile.psp"
  ];
  buildTarget = "release";

  installPhase = ''
    runHook preInstall
    install -Dm644 lib/libintrafont.a "$out/psp/lib/libintrafont.a"
    mkdir -p "$out/psp/include"
    cp include/*.h "$out/psp/include/"
    install -Dm644 LICENSE "$out/share/licenses/libintrafont/LICENSE"
    runHook postInstall
  '';

  meta = {
    description = "Font library using the PSP's internal fonts";
    homepage = "https://github.com/pspdev/libintrafont";
    license = lib.licenses.cc-by-sa-30;
    platforms = lib.platforms.all;
  };
}
