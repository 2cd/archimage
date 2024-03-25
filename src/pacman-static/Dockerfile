# syntax=docker/dockerfile:1
FROM ghcr.io/archlinux/archlinux as arch
FROM ghcr.io/2moe/zsh-static as zsh
FROM curlimages/curl as pacman-static

ARG OPT=/opt/bin
COPY --from=zsh ${OPT}/zsh /app/
# -----------------
USER 0:0

# build-args
ARG REGION
ARG OS_ARCH=x86_64
# -----------------
RUN <<GET_PACMAN
#!/app/zsh
    set -fexo pipefail

    download() {
        case $REGION {
            (CN) local mirror_url=https://mirrors.tuna.tsinghua.edu.cn/arch4edu/${OS_ARCH}/ ;;
            (*) local mirror_url=https://repository.arch4edu.org/${OS_ARCH}/ ;;
        }
        pkg=$(
            awk_args=(
                -F 'href='
                '/pacman-static/ && !/\.sig|debug/ {
                    pkg_html = $2
                } END {
                    split(pkg_html, pkg_arr, "\"")
                    print(pkg_arr[2])
                }'
            )
            curl -L $mirror_url | awk $awk_args
        )

        case $pkg {
            (pacman-*tar.*) ;;
            (*) pkg=pacman-static-6.1.0-1-x86_64.pkg.tar.zst ;;
        }
        curl -Lo $pkg ${mirror_url}${pkg}
    }

    extract_pkg() {
        mkdir -p tmp
        apk add libarchive-tools
        bsdtar -C tmp -xf $pkg
        for bin (pacman-static pacman-conf-static) {
            mv -vf tmp/usr/bin/$bin /app/
        }
    }
    download
    extract_pkg
GET_PACMAN
# ---------------------
# ---------------------
# FROM scratch
FROM zsh
# ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/local/games:/bin:/usr/games:/opt/bin
ARG BIN=/opt/bin/
COPY --from=pacman-static --chmod=755 /app/zsh /app/pacman-static /app/pacman-conf-static ${BIN}

COPY --chmod=755 <<'EOF' ${BIN}pacman
#!/opt/bin/ash
pacman=/opt/bin/pacman
${pacman}-static -Syy pacman --overwrite '*' && {
    [ -e /bin/pacman ] && {
        rm -vf ${pacman}
        echo >&2 "/bin/pacman $*"
        /bin/pacman "$@"
        echo >&2 "run 'hash -r' to reset the command hash table"
    }
}
EOF

# src: ../../ca-certificates/extracted/tls-ca-bundle.pem
# link: /etc/ssl/certs/ca-certificates.crt
ARG CA_FILE=/etc/ca-certificates/extracted/tls-ca-bundle.pem
ARG TLS_CRT=/etc/ssl/certs/ca-certificates.crt
COPY --from=arch ${CA_FILE} ${CA_FILE}
COPY --from=arch ${TLS_CRT} ${TLS_CRT}
COPY . /etc/

RUN <<EOF
    ln -svf ${CA_FILE} ${TLS_CRT}

    cd /opt/bin

    ln -svf $PWD/pacman-static /opt/pack

    chmod 755 -v /etc/pacman.d

    cd /etc/pacman.d/repos
    for i (disabled/x86_64/*conf) {
        cp -Lvf $i .
    }

    cd ../options
    ln -svf bak/siglevel-never.conf ./sig-level.conf
    mkdir -p /var/lib/pacman/
EOF

CMD ["/opt/bin/ash"]
