{
  fetchurl,
  fetchpatch,
  stdenv,
  meson,
  ninja,
  pkg-config,
  gettext,
  libarchive,
  curl,
  gpgme,
  openssl,
  zlib,
  bash,
  coreutils,
  gnused,
  gawk,
  python3,
  psp-binutils,
  psp-gcc,
  psp-pkg-config,
}:
stdenv.mkDerivation rec {
  pname = "psp-pacman";
  version = "6.0.1";

  src = fetchurl {
    url = "https://gitlab.archlinux.org/pacman/pacman/-/archive/v${version}/pacman-v${version}.tar.gz";
    hash = "sha256-aP9M0aooYOWDo6bJrJJmVBeyPj/3s43+x9FQjEYIfg8=";
  };

  patches = [
    (fetchpatch {
      url = "https://raw.githubusercontent.com/pspdev/psp-pacman/master/patches/pacman-6.0.1.patch";
      hash = "sha256-FYvkGqi4crJuuxa05eYCMqbkyYJDY3RPFjfz9HuLFUg=";
    })
    (fetchpatch {
      url = "https://raw.githubusercontent.com/pspdev/psp-pacman/master/patches/147.patch";
      hash = "sha256-PZANtg4jQhsxvNxEsg9piz5WsujecjFEoHAGo7ZA+fM=";
    })
  ];

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    gettext
    gnused
    gawk
    python3
  ];

  buildInputs = [
    libarchive
    curl
    gpgme
    openssl
    zlib
  ];

  configurePhase = ''
    runHook preConfigure

    while IFS= read -r file; do
      substituteInPlace "$file" --replace-quiet "@libmakepkgdir@" "$out/share/makepkg"
      substituteInPlace "$file" --replace-quiet "declare -r confdir='@sysconfdir@'" "declare -r confdir=\"$out/share/psp-pacman/default-etc\""
      substituteInPlace "$file" --replace-quiet "export TEXTDOMAINDIR='@localedir@'" "export TEXTDOMAINDIR=\"$out/share/locale\""
    done < <(find scripts -type f -name "*.in")

    meson setup build \
      -Dbuildtype=release \
      -Ddefault_library=static \
      -Dbuildscript=PSPBUILD \
      -Dprefix=$out \
      -Dsysconfdir=$out/share/psp-pacman/default-etc \
      -Dbindir=$out/libexec/psp-pacman/bin \
      -Dlocalstatedir=$out/share/psp-pacman/default-var \
      -Ddoc=disabled \
      -Di18n=false

    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild
    ninja -C build
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    ninja -C build install

    mkdir -p "$out/share/psp-pacman/default-etc"
    cat > "$out/share/psp-pacman/default-etc/pacman.conf" <<'EOF'
[options]
Architecture = mips
CheckSpace
DisableDownloadTimeout

[pspdev]
SigLevel = Optional TrustAll
Server = https://pspdev.github.io/psp-packages/
EOF

    cat > "$out/share/psp-pacman/default-etc/makepkg.conf" <<'EOF'
AR="psp-ar"
RANLIB="psp-ranlib"
CC="psp-gcc"
CXX="psp-g++"
CARCH="mips"
CHOST="psp"
MAKEFLAGS="-j$(getconf _NPROCESSORS_ONLN)"
OPTIONS=(strip docs libtool staticlibs emptydirs zipman purge !debug)
INTEGRITY_CHECK=(ck)
STRIP_BINARIES="--strip-all"
STRIP_SHARED="--strip-unneeded"
STRIP_STATIC="--strip-debug"
PKGEXT='.pkg.tar.gz'
SRCEXT='.src.tar.gz'
EOF

    mkdir -p "$out/bin"
    cat > "$out/bin/psp-pacman" <<'EOF'
#!__SHELL__
set -eu

PSP_PACMAN_ROOT="''${PSP_PACMAN_ROOT:-''${XDG_DATA_HOME:-$HOME/.local/share}/pspdev}"

mkdir -p \
  "''${PSP_PACMAN_ROOT}/etc/pacman.d/gnupg" \
  "''${PSP_PACMAN_ROOT}/etc/pacman.d/hooks" \
  "''${PSP_PACMAN_ROOT}/share/libalpm/hooks" \
  "''${PSP_PACMAN_ROOT}/var/lib/pacman" \
  "''${PSP_PACMAN_ROOT}/var/cache/pacman/pkg" \
  "''${PSP_PACMAN_ROOT}/var/log"

if [ ! -f "''${PSP_PACMAN_ROOT}/etc/pacman.conf" ]; then
  cp "__OUT__/share/psp-pacman/default-etc/pacman.conf" "''${PSP_PACMAN_ROOT}/etc/pacman.conf"
fi

export PATH="__OUT__/libexec/psp-pacman/bin:__BINUTILS__/bin:__GCC__/bin:__COREUTILS__/bin:__GNUSED__/bin:__GAWK__/bin:''${PATH}"

exec pacman \
  --root "''${PSP_PACMAN_ROOT}" \
  --dbpath "''${PSP_PACMAN_ROOT}/var/lib/pacman" \
  --config "''${PSP_PACMAN_ROOT}/etc/pacman.conf" \
  --cachedir "''${PSP_PACMAN_ROOT}/var/cache/pacman/pkg" \
  --gpgdir "''${PSP_PACMAN_ROOT}/etc/pacman.d/gnupg" \
  --logfile "''${PSP_PACMAN_ROOT}/var/log/pacman.log" \
  --hookdir "''${PSP_PACMAN_ROOT}/share/libalpm/hooks" \
  --hookdir "''${PSP_PACMAN_ROOT}/etc/pacman.d/hooks" \
  "''${@}"
EOF

    cat > "$out/bin/psp-makepkg" <<'EOF'
#!__SHELL__
set -eu

PSP_PACMAN_ROOT="''${PSP_PACMAN_ROOT:-''${XDG_DATA_HOME:-$HOME/.local/share}/pspdev}"

mkdir -p "''${PSP_PACMAN_ROOT}/etc"
if [ ! -f "''${PSP_PACMAN_ROOT}/etc/makepkg.conf" ]; then
  cp "__OUT__/share/psp-pacman/default-etc/makepkg.conf" "''${PSP_PACMAN_ROOT}/etc/makepkg.conf"
fi

export PATH="__OUT__/libexec/psp-pacman/bin:__BINUTILS__/bin:__GCC__/bin:__PKGCONFIG__/bin:__COREUTILS__/bin:__GNUSED__/bin:__GAWK__/bin:''${PATH}"
export PACMAN=psp-pacman
export MAKEPKG_CONF="''${PSP_PACMAN_ROOT}/etc/makepkg.conf"

exec makepkg "''${@}"
EOF

    substituteInPlace "$out/bin/psp-pacman" --replace-fail "__SHELL__" "${stdenv.shell}"
    substituteInPlace "$out/bin/psp-pacman" --replace-fail "__OUT__" "$out"
    substituteInPlace "$out/bin/psp-pacman" --replace-fail "__BINUTILS__" "${psp-binutils}"
    substituteInPlace "$out/bin/psp-pacman" --replace-fail "__GCC__" "${psp-gcc}"
    substituteInPlace "$out/bin/psp-pacman" --replace-fail "__COREUTILS__" "${coreutils}"
    substituteInPlace "$out/bin/psp-pacman" --replace-fail "__GNUSED__" "${gnused}"
    substituteInPlace "$out/bin/psp-pacman" --replace-fail "__GAWK__" "${gawk}"

    substituteInPlace "$out/bin/psp-makepkg" --replace-fail "__SHELL__" "${stdenv.shell}"
    substituteInPlace "$out/bin/psp-makepkg" --replace-fail "__OUT__" "$out"
    substituteInPlace "$out/bin/psp-makepkg" --replace-fail "__BINUTILS__" "${psp-binutils}"
    substituteInPlace "$out/bin/psp-makepkg" --replace-fail "__GCC__" "${psp-gcc}"
    substituteInPlace "$out/bin/psp-makepkg" --replace-fail "__PKGCONFIG__" "${psp-pkg-config}"
    substituteInPlace "$out/bin/psp-makepkg" --replace-fail "__COREUTILS__" "${coreutils}"
    substituteInPlace "$out/bin/psp-makepkg" --replace-fail "__GNUSED__" "${gnused}"
    substituteInPlace "$out/bin/psp-makepkg" --replace-fail "__GAWK__" "${gawk}"

    chmod +x "$out/bin/psp-pacman" "$out/bin/psp-makepkg"

    runHook postInstall
  '';
}
