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
  version = "b03c8d92a2ed6c81ad2313b043611ae6ba0f46f2";

  src = fetchFromGitHub {
    owner = "pspdev";
    repo = "psp-cfw-sdk";
    rev = version;
    hash = "sha256-Vd8QehOZZGFywAYSw7UEQyoXpPqvYOAzu+5rp7I87XE=";
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

  postPatch = ''
    # Upstream's CMake build omits libraries used by ARK-5 and its updater.
    cat >> src/CMakeLists.txt <<'EOF'

    add_sdk_library(popsdisplay)
    target_sources(popsdisplay PRIVATE popsdisplay/popsdisplay.c)
    target_compile_options(popsdisplay PRIVATE -O3 -fno-builtin)

    add_sdk_library(pspminicrt)
    target_sources(pspminicrt PRIVATE pspminicrt/crt0.c)
    target_compile_options(pspminicrt PRIVATE -fno-builtin)

    add_sdk_library(pspmalloc)
    target_sources(pspmalloc PRIVATE pspmalloc/pspmalloc.c)
    target_compile_options(pspmalloc PRIVATE -fno-builtin)
    EOF
  '';

  preBuild = ''
    # mirror the old Makefile staging behavior that upstream expects
    mkdir -p include/iplsdk
    cp -f src/LibPspExploit/libpspexploit.h include/
    cp -f src/BootLoadEx/*.h include/
    cp -f src/popsdisplay/*.h include/
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
