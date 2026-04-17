{
  stdenv,
  pspsdk,
  pkg-config,
}:
stdenv.mkDerivation {
  pname = "psp-pkg-config";
  version = "ce8127a5d7de5a8774bf1f7f152501dae0a800ae";

  dontUnpack = true;

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/bin"

    cat > "$out/bin/psp-pkg-config" <<'EOF'
    #!${stdenv.shell}
    command -v ${pkg-config}/bin/pkg-config >/dev/null 2>&1 || {
      echo >&2 "I require pkg-config but it is not installed."
      exit 1
    }

    if [ -z "''${PSPDEV}" ]; then
      export PSPDEV="${pspsdk}"
    fi

    PSP_PACMAN_ROOT="''${PSP_PACMAN_ROOT:-''${XDG_DATA_HOME:-$HOME/.local/share}/pspdev}"

    export PKG_CONFIG_DIR=
    export PKG_CONFIG_PATH=
    export PKG_CONFIG_SYSROOT_DIR=
    export PKG_CONFIG_LIBDIR="''${PSPDEV}/psp/lib/pkgconfig:''${PSPDEV}/psp/share/pkgconfig:''${PSP_PACMAN_ROOT}/psp/lib/pkgconfig:''${PSP_PACMAN_ROOT}/psp/share/pkgconfig"

    if [ "''${1:-}" = "--version" ]; then
      exec ${pkg-config}/bin/pkg-config --version
    fi

    exec ${pkg-config}/bin/pkg-config --define-prefix --define-variable=PSPDEV="''${PSPDEV}" --static "$@"
    EOF

    chmod +x "$out/bin/psp-pkg-config"
    ln -s psp-pkg-config "$out/bin/psp-pkgconf"
    runHook postInstall
  '';
}
