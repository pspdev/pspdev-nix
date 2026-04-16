{
  lib,
  psp-libpng,
  psp-lz4,
  psp-minilzo,
  fetchFromGitHub,
  pspMkLibraryDerivation,
}:

pspMkLibraryDerivation rec {
  pname = "psp-cfw-sdk";
  version = "ddc045413798b2916f21b00cb41fe2f2d33be65a";

  src = fetchFromGitHub {
    owner = "pspdev";
    repo = "psp-cfw-sdk";
    rev = version;
    hash = "sha256-sq3nPsiR8uOr7EmponOFigm2bXoaFrm8imJOpygnghw=";
  };

  buildSystem = "cmake";

  buildInputs = [
    psp-libpng
    psp-lz4
    psp-minilzo
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/psp/include" "$out/psp/lib" "$out/bin"

    cp -r include/. "$out/psp/include/"

    find libs -type f \( -name '*.a' -o -name '*.prx' \) \
      -exec install -m644 -t "$out/psp/lib" {} +

    find build -type f \( -name '*.a' -o -name '*.prx' \) \
      -exec install -m644 -t "$out/psp/lib" {} +

    runHook postInstall
  '';

  meta = with lib; {
    description = "PSP custom firmware SDK extension libraries";
    homepage = "https://github.com/pspdev/psp-cfw-sdk";
    license = licenses.gpl2Plus;
    platforms = platforms.all;
  };
}
