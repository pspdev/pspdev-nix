{
  lib,
  stdenv,
  clang-tools,
  makeWrapper,
  psp-gcc,
}:
let
  queryDrivers = lib.concatStringsSep "," [
    "${psp-gcc}/bin/psp-gcc"
    "${psp-gcc}/bin/psp-g++"
    "${psp-gcc}/bin/psp-c++"
    "${psp-gcc}/bin/psp-cpp"
  ];
in
stdenv.mkDerivation {
  pname = "psp-clangd";
  version = "ce8127a5d7de5a8774bf1f7f152501dae0a800ae";

  dontUnpack = true;
  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/bin"

    makeWrapper ${clang-tools}/bin/clangd "$out/bin/clangd" \
      --add-flags "--query-driver=${queryDrivers}"

    runHook postInstall
  '';

  meta = clang-tools.meta or { };
}
