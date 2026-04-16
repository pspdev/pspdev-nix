{
  lib,
  stdenv,
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

  # static archives are the main reproducibility risk here
  env.ZERO_AR_DATE = "1";

  # we don't want random empty bin outputs
  dontStrip = true;

  postBuild = ''
    # mirror the old Makefile staging behavior that upstream expects
    mkdir -p include/iplsdk
    cp -f src/LibPspExploit/libpspexploit.h include/
    cp -f src/iplsdk/include/*.h include/iplsdk/
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p \
      "$out/psp/include" \
      "$out/psp/lib" \
      "$out/share/psp-cfw-sdk"

    cp -r include/. "$out/psp/include/"

    find libs -maxdepth 1 -type f \( -name '*.a' -o -name '*.prx' \) -print0 \
      | sort -z \
      | xargs -0r install -m644 -t "$out/psp/lib"

    cp -r build-tools "$out/"
    ln -sf "$out/build-tools" "$out/share/psp-cfw-sdk/"

    runHook postInstall
  '';

  meta = with lib; {
    description = "PSP custom firmware SDK extension libraries";
    homepage = "https://github.com/pspdev/psp-cfw-sdk";
    license = licenses.gpl2Plus;
    platforms = platforms.all;
  };
}
