{
  lib,
  fetchFromGitHub,
  pspMkDerivation,
  stdenvNoCC,
  python3,
  which,
  zip,
  psp-ark-5,
  psp-cfw-sdk,
  psp-ya2d,
  psp-libpspmath,
  psp-libpspvram,
  psp-libpng,
  psp-zlib,
  variant ? "psp",
}:
assert builtins.elem variant [
  "psp"
  "themes"
  "updater"
];
let
  mkDerivation = if variant == "themes" then stdenvNoCC.mkDerivation else pspMkDerivation;
in
mkDerivation {
  pname = "fasterark-${variant}";
  version = "393bc556f67dc4cedbd222f88c7dd4fa0c03fa48";

  src = fetchFromGitHub {
    owner = "PSP-Arkfive";
    repo = "FasterARK";
    rev = "393bc556f67dc4cedbd222f88c7dd4fa0c03fa48";
    hash = "sha256-xeQKQ+1JxRuWxCj5kfZIBX5VeXv5766HQN8sDy0JRIY=";
  };

  outputs = [
    "out"
  ]
  ++ lib.optionals (variant == "psp") [
    "full"
    "lite"
  ];

  nativeBuildInputs = [
    python3
    which
    zip
  ];
  buildInputs = lib.optionals (variant != "themes") [
    psp-cfw-sdk
    psp-ya2d
    psp-libpspmath
    psp-libpspvram
    psp-libpng
    psp-zlib
  ];

  # Upstream targets share a temporary packaging directory.
  enableParallelBuilding = false;
  dontStrip = true;
  dontConfigure = true;

  postPatch = lib.optionalString (variant != "themes") ''
    cp ${psp-ark-5}/FLASH0.ARK Resources/ARK_01234/FLASH0.ARK
  '';

  buildPhase = ''
    runHook preBuild
    make ${variant} ${lib.optionalString (variant != "themes") "BUILDTOOLS=${psp-cfw-sdk}/build-tools"}

    # ZIP timestamps otherwise depend on when the installers were compiled.
    python3 - <<'PY'
    import os, time, zipfile
    from pathlib import Path

    timestamp = time.gmtime(max(315532800, int(os.environ["SOURCE_DATE_EPOCH"])))[:6]
    for archive in Path("dist").glob("*.zip"):
        normalized = archive.with_suffix(".normalized")
        with zipfile.ZipFile(archive) as src, zipfile.ZipFile(normalized, "w") as dst:
            for entry in sorted(src.infolist(), key=lambda entry: entry.filename):
                entry.date_time = timestamp
                entry.extra = b""
                entry.comment = b""
                dst.writestr(entry, src.read(entry.filename))
        normalized.replace(archive)
    PY
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
  ''
  + (
    if variant == "psp" then
      ''
        install -Dm644 dist/FasterARK_psp_full.zip "$full/FasterARK_psp_full.zip"
        install -Dm644 dist/FasterARK_psp_lite.zip "$lite/FasterARK_psp_lite.zip"
        mkdir -p "$out"
        ln -s "$full/FasterARK_psp_full.zip" "$out/"
        ln -s "$lite/FasterARK_psp_lite.zip" "$out/"
      ''
    else if variant == "themes" then
      ''
        install -Dm644 dist/themes.zip "$out/themes.zip"
      ''
    else
      ''
        install -Dm644 dist/ARK_UPDATE.zip "$out/ARK_UPDATE.zip"
      ''
  )
  + ''
    runHook postInstall
  '';

  meta = {
    description = "ARK loader/installer for PSP";
    homepage = "https://github.com/PSP-Arkfive/FasterARK";
    platforms = lib.platforms.all;
  };
}
