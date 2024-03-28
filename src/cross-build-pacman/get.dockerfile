# syntax=docker/dockerfile:1
FROM --platform=${BUILDPLATFORM} ghcr.io/2moe/zsh-static as zsh-host
FROM ghcr.io/2moe/zsh-static as zsh
FROM --platform=${BUILDPLATFORM} curlimages/curl as pacman-app
# build-args:
ARG OS_ARCH
ARG REGION
COPY --from=zsh-host /opt/bin/zsh /app/
USER 0:0
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
            (pacman-static-*tar.*) ;;
            (*) pkg=pacman-static-6.1.0-1-${OS_ARCH}.pkg.tar.zst ;;
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

FROM zsh
COPY --from=pacman-app /app/* /opt/bin/
