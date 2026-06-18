{
  lib,
  fetchFromGitHub,
  pspMkLibraryDerivation,
}:

pspMkLibraryDerivation rec {
  pname = "psp-pspgl";
  version = "r12";

  src = fetchFromGitHub {
    owner = "pspdev";
    repo = "pspgl";
    rev = "de4260adf56d06516ec46018d404ca77e0b61748";
    hash = "sha256-SQwy5eMNsDPCaezS9wTWUOnCXQ3F9eBrE+pI+orYwhs=";
  };

  buildSystem = "custom";

  buildPhase = ''
    runHook preBuild

    make -j$NIX_BUILD_CORES

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/psp/lib" "$out/psp/include/GL" "$out/psp/include/GLES" "$out/psp/share/licenses/psp-pspgl"
    install -m644 libGL.a "$out/psp/lib/"
    install -m644 libGLU.a "$out/psp/lib/"
    install -m644 libglut.a "$out/psp/lib/"
    install -m644 GL/* "$out/psp/include/GL/"
    install -m644 GLES/* "$out/psp/include/GLES/"
    install -m644 LICENSE "$out/psp/share/licenses/psp-pspgl/"

    runHook postInstall
  '';

  doCheck = false;

  meta = {
    description = "OpenGL-ESish library for PSP";
    homepage = "https://github.com/pspdev/pspgl";
    license = lib.licenses.bsd3;
    platforms = lib.platforms.all;
  };
}
