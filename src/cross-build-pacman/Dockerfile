# syntax=docker/dockerfile:1
ARG ARCH
FROM ghcr.io/2cd/arch-dev:${ARCH} as dev
USER 0:0

ARG MAKECFG=makepkg.conf
COPY <<'NODEBUG' /tmp/_${MAKECFG}
OPTIONS+=('!debug')
MAKEFLAGS="-j$(nproc)"
NODEBUG

RUN <<EOF
    cat /tmp/_${MAKECFG} >> /etc/${MAKECFG}
    cat /etc/${MAKECFG}
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
    makepkg -s --noconfirm --skippgpcheck
    sudo mkdir -p /app
    sudo cp pkg/pacman-static/usr/bin/pacman-*static /app
EOF

FROM ghcr.io/2moe/zsh-static
COPY --from=dev /app/* /opt/bin/
