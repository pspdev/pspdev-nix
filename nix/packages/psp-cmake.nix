{
  stdenv,
  makeWrapper,
  cmake,
  pspsdk,
  psp-gcc,
  psp-pkg-config,
}:
stdenv.mkDerivation {
  pname = "psp-cmake";
  version = "ce8127a5d7de5a8774bf1f7f152501dae0a800ae";

  dontUnpack = true;
  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/bin"
    mkdir -p "$out/share/pspdev-nix"

    cat > "$out/share/pspdev-nix/psp-toolchain.cmake" <<'EOF'
    if(DEFINED ENV{PSPDEV})
      set(PSPDEV $ENV{PSPDEV})
    else()
      message(FATAL_ERROR "The environment variable PSPDEV needs to be defined.")
    endif()

    include("''${PSPDEV}/psp/share/pspdev.cmake")

    # Avoid PATH-dependent compiler resolution.
    set(CMAKE_C_COMPILER "${psp-gcc}/bin/psp-gcc" CACHE FILEPATH "" FORCE)
    set(CMAKE_CXX_COMPILER "${psp-gcc}/bin/psp-g++" CACHE FILEPATH "" FORCE)
    set(PKG_CONFIG_EXECUTABLE "${psp-pkg-config}/bin/psp-pkg-config" CACHE FILEPATH "" FORCE)

    if(NOT DEFINED CMAKE_C_STANDARD_LIBRARIES OR CMAKE_C_STANDARD_LIBRARIES STREQUAL "")
      set(CMAKE_C_STANDARD_LIBRARIES "-lc -lm -lpthreadglue -lpthread -lcglue -lgcc" CACHE STRING "" FORCE)
    endif()

    if(NOT DEFINED CMAKE_CXX_STANDARD_LIBRARIES OR CMAKE_CXX_STANDARD_LIBRARIES STREQUAL "")
      set(CMAKE_CXX_STANDARD_LIBRARIES "-lc -lm -lpthreadglue -lpthread -lcglue -lgcc" CACHE STRING "" FORCE)
    endif()
    EOF

    cat > "$out/bin/psp-cmake" <<'EOF'
    #!@shell@
    if [ -z "''${PSPDEV}" ]; then
      export PSPDEV="@pspdev@"
    fi

    has_generator=0
    expect_generator_value=0

    for arg in "$@"; do
      if [ "$expect_generator_value" -eq 1 ]; then
        has_generator=1
        expect_generator_value=0
        continue
      fi

      case "$arg" in
        --build|--install|--open|-P|-E|--find-package)
          exec @cmake@ "$@"
          ;;
        -G|-A|--generator|--toolset|--platform)
          has_generator=1
          expect_generator_value=1
          ;;
        -G*|--generator=*|--toolset=*|--platform=*)
          has_generator=1
          ;;
      esac
    done

    if [ "$has_generator" -eq 0 ] && command -v ninja >/dev/null 2>&1; then
      exec @cmake@ -GNinja -DCMAKE_TOOLCHAIN_FILE="@out@/share/pspdev-nix/psp-toolchain.cmake" "$@"
    fi

    exec @cmake@ -DCMAKE_TOOLCHAIN_FILE="@out@/share/pspdev-nix/psp-toolchain.cmake" "$@"
    EOF
    substituteInPlace "$out/bin/psp-cmake" \
      --replace "@shell@" "${stdenv.shell}" \
      --replace "@pspdev@" "${pspsdk}" \
      --replace "@cmake@" "${cmake}/bin/cmake" \
      --replace "@out@" "$out"
    chmod +x "$out/bin/psp-cmake"
    runHook postInstall
  '';
}
