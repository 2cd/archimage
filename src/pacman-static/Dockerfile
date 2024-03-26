# syntax=docker/dockerfile:1
FROM ghcr.io/2cd/arch-slim:x64 as arch
FROM ghcr.io/2moe/zsh-static as zsh

# -----------------
# -----------------
FROM curlimages/curl as pacman-static
COPY --from=zsh /opt/bin/zsh /app/
USER 0:0
# build-args:
ARG OS_ARCH
ARG REGION
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

# -----------------
# -----------------
FROM zsh as ca-certs
# src: ../../ca-certificates/extracted/tls-ca-bundle.pem
# link: /etc/ssl/certs/ca-certificates.crt
ARG CA_FILE=/etc/ca-certificates/extracted/tls-ca-bundle.pem
ARG TLS_CRT=/etc/ssl/certs/ca-certificates.crt
COPY --from=arch ${CA_FILE} ${CA_FILE}
COPY --from=arch ${TLS_CRT} ${TLS_CRT}
# ARG TERM_INFO=/usr/share/terminfo
# COPY --from=arch ${TERM_INFO} ${TERM_INFO}
COPY . /etc/

ARG OS_ARCH
RUN <<UPDATE_PACMAN_D
#!/opt/bin/zsh
set -fexo pipefail

    ln -svf ${CA_FILE} ${TLS_CRT}
    cd /opt/bin
    ln -svf $PWD/pacman-static /opt/pack

    cd /opt

    chmod 755 -v /etc/pacman.d

    cd /etc/pacman.d/repos
    for i (disabled/${OS_ARCH}/*conf) {
        cp -Lvf $i .
    }

    cd ../options
    ln -svf bak/siglevel-never.conf ./sig-level.conf
    mkdir -p /var/lib/pacman/
    rm /*.core ||:
UPDATE_PACMAN_D
# -------------
ARG OPT=/opt/bin
COPY --chmod=755 <<'PRINT_CMD' ${OPT}/print-cmd
#!/opt/bin/zsh -fe
    args=("%F{green}$1%f")
    shift
    for a ($*) {
        case $a {
            (--*)  args+="%F{blue}$a%f"  ;;
            (-*)   args+="%F{cyan}$a%f"  ;;
            (*)    args+=$a              ;;
        }
    }
    print -Pr >&2 -- "$args"
PRINT_CMD

COPY --chmod=755 <<'PACMAN_ALT' ${OPT}/pacman
#!/opt/bin/zsh
set -feo pipefail
    local -r src=${0:a}

    stderr() {
        print -Pr >&2 -- "$*"
    }

    bin_pacman=/bin/pacman
    opt_pacman=/opt$bin_pacman
    local cmd
    if [[ -e $bin_pacman ]] {
        cmd=(unlink $src)
        print-cmd $cmd
        $cmd

        cmd=($bin_pacman $*)
        print-cmd $cmd
        $cmd
        local status=$?

        stderr run %F{green}hash %F{cyan}-r%f to reset the command hash table.
        exit $status
    }

    if ((# == 0)) {
        ${opt_pacman}-static
        exit $?
    }
    case $1 {
        (-S*)
            cmd=(${opt_pacman}-static $* --overwrite '*')
            print-cmd $cmd
            $cmd
        ;;
        (*) ${opt_pacman}-static $* ;;
    }
PACMAN_ALT

COPY --chmod=755 <<'PACMAN_INSTALL' ${OPT}/pacman-install
#!/opt/bin/zsh
set -feo pipefail
    stderr() {
        print -Pr >&2 -- "$*"
    }
    error() {
        stderr "%F{red}[ERROR]%f $*"
    }

    cmd=()
    if (( $(id -u) != 0 )) {
        stderr '%F{yellow}[WARN]%f You should run it as %F{magenta}root%f.'
        for v (sudo doas) {
            if (($+commands[$v])) {
                cmd+=$v
            }
        }
        if ((! $+cmd[1])) {
            exit 1
        }
    }
    pacman_installed=false
    for i (/opt/bin/pacman-static /bin/pacman $commands[pacman]) {
        if [[ -e $i ]] {
            cmd+=$i
            pacman_installed=true
            break
        }
    }
    if {! $pacman_installed} {
        error "Please install %F{blue}pacman%f first."
        exit 127
    }
    if ((! #1)) {
        cmd+="-Syu"
        print-cmd $cmd
        $cmd
        exit $?
    }

    installation_cmd=(
        $cmd
        -Sy
        --overwrite '*'
        --noconfirm
        --needed
    )
    failures=()
    for pkg ($*) {
        cmd=($installation_cmd $pkg)
        print-cmd $cmd
        $cmd || failures+=$pkg
    }

    if (($+failures[1])) {
        (
            IFS=,
            error "Failed to install %F{blue}$failures%f"
        )
        exit 1
    }
PACMAN_INSTALL

COPY --chmod=744 <<'FIX_USERADD' ${OPT}/fix-useradd-no-users
#!/opt/bin/zsh
    set -feo pipefail
    stderr() {
        print -Pr >&2 -- "$*"
    }
    if (( $(id -u) != 0 )) {
        stderr 'You should run it as %F{magenta}root%f.'
        exit 1
    }

    if ((! $+commands[groupadd])) {
        cmd=(
            /opt/bin/pacman-static
            -Sy shadow
            --overwrite '*'
        )
        print-cmd $cmd
        $cmd || exit 127
    }

    cmd=(getent group users)
    ! $cmd || {
        stderr '%F{yellow}[WARN]%f do nothing!'
        exit 0
    }

    cmd=(
        groupadd
        --gid 984
        --system
        --force
        users
    )
    print-cmd $cmd
    $cmd && {
        stderr 'OK! Now try running %F{green}useradd %F{cyan}-m %F{blue}[username]%f (e.g., %F{green}useradd %F{cyan}-m%f user)'
    }
FIX_USERADD
# ---------------------
# ---------------------
# FROM scratch
# COPY --from=ca-certs / /
# ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/local/games:/bin:/usr/games:/opt/sbin:/opt/bin
# SHELL [ "/opt/bin/zsh", "--pipefail", "-fexc"]

FROM ca-certs
COPY --from=pacman-static --chmod=755 /app/* /opt/bin/
CMD ["/opt/bin/ash"]
