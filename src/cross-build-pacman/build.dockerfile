# syntax=docker/dockerfile:1
ARG ARCH
FROM ghcr.io/2cd/arch-dev:${ARCH} as dev
USER 0:0

ARG MK_CFG=makepkg.conf
ARG TMP_CFG=/tmp/_${MK_CFG}
COPY <<'NO_DEBUG' ${TMP_CFG}
OPTIONS+=('!debug')
MAKEFLAGS="-j$(nproc)"
NO_DEBUG

ARG CFG=/etc/${MK_CFG}
RUN <<EOF
    cat ${TMP_CFG} >> ${CFG}
    cat ${CFG}
EOF

USER user:wheel
RUN <<'EOF'
#!/opt/bin/zsh
set -feo pipefail
    cmd=(
        curl -Lo p.tgz
        'https://aur.archlinux.org/cgit/aur.git/snapshot/aur-pacman-static.tar.gz'
    )
    cd /tmp
    $cmd
    tar -xvf p.tgz
    cd aur-pacman-static/
    sudo pacman -Sy
    # pacman-install openssl clang ||:

    archs=('riscv64' 'loong64' 'powerpc' 'powerpc64' 'powerpc64le' 'i486' 'i686' 'pentium4' 'x86_64' 'arm' 'armv6h' 'armv7h' 'aarch64')
    sed -E "/aarch64/ s@^(arch=).*@\1($archs)@" -i PKGBUILD
    makepkg -s --noconfirm --skippgpcheck
    sudo mkdir -p /app
    sudo cp pkg/pacman-static/usr/bin/pacman-*static /app
EOF

FROM ghcr.io/2moe/zsh-static
COPY --from=dev /app/* /opt/bin/
