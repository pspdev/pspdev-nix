{
  lib,
  fetchFromGitHub,
  pspMkLibraryDerivation,
  psp-libpspvram,
}:
pspMkLibraryDerivation {
  pname = "psp-libpspav";
  version = "r15";

  src = fetchFromGitHub {
    owner = "pspdev";
    repo = "libpspav";
    rev = "6dd1f9fb535614c708b57cc2d3d46dd8656a49f7";
    hash = "sha256-JCIyDzMY//9mbSwm7URDGiInoPm8DaBHfuZJNhrZB2o=";
  };

  buildInputs = [ psp-libpspvram ];

  installPhase = ''
    runHook preInstall
    install -Dm644 libpspav.a "$out/psp/lib/libpspav.a"
    mkdir -p "$out/psp/include/pspav"
    cp include/*.h "$out/psp/include/pspav/"
    install -Dm644 LICENSE "$out/share/licenses/libpspav/LICENSE"
    runHook postInstall
  '';

  meta = {
    description = "A library that allows you to easily embed a native at3, pmf, and mps video/audio player in your homebrew.";
    homepage = "https://github.com/pspdev/libpspav";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
}
