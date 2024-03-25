# syntax=docker/dockerfile:1
ARG TMM_ARCH_V0
FROM ghcr.io/2moe/zsh-static:${TMM_ARCH_V0} as zsh-tmm-arch
FROM ghcr.io/2cd/pacman-static:x64

RUN rm -rf /etc/pacman.d
COPY . /etc
# ------------------------
# build-args:
ARG OS_ARCH=x86_64
ARG TMM_ARCH
ARG SLIM=false
#
# 2cd/pacman-static:x64
# 2cd/arch:loong64
# 2cd/arch:x64
# 2cd/arch:x64v2
# 2cd/arch:x64v3
# 2cd/arch:x64v4
# 2cd/arch:i686
#
# 2cd/arch-base
# 2cd/arch-dev
# 2cd/arch-slim
# 2cd/arch-testing
# 2cd/arch-archive
#
# reg.tmoe.me:2096/arch/latest:x64
# reg.tmoe.me:2096/arch/pacman:x64
# reg.tmoe.me:2096/arch/base:x64
#
ARG REPO_DIR=/etc/pacman.d/repos
ARG DISABLED_DIR=${REPO_DIR}/disabled/${OS_ARCH}
ARG OPTIONS_DIR=/etc/pacman.d/options
RUN <<ADD_REPOS
#!/opt/bin/zsh
set -fexo pipefail
    mkdir -p /opt/info
    print $(date "+%Y-%m-%d %H:%M:%s")Z > /opt/info/start-build-time.txt

    cd ${OPTIONS_DIR}
    ln -svf bak/siglevel-never.conf ./sig-level.conf
    slim_conf=no-extract.conf
    if {$SLIM} {
        mv ${slim_conf}.ini $slim_conf
    }

    cd ${DISABLED_DIR}
    # -----------
    x64v2=false
    x64v3=false
    x64v4=false
    case $TMM_ARCH {
        (x64v2) x64v2=true ;;
        (x64v3)
            x64v3=true
            # x64v2=true
        ;;
        (x64v4)
            x64v4=true
            # x64v3=true
        ;;
    }
    x64_map=(
        19-v2 $x64v2
        18-v3 $x64v3
        17-v4 $x64v4
    )
    local cfg
    for k v (${(kv)x64_map}) {
        if {$v} {
            cfg=${k}.conf
            mv -vf ${cfg}.ini $cfg
        }
    }
    # -----------
    for i (${DISABLED_DIR}/*.conf) {
        cp -Lvf $i ${REPO_DIR}
    }
    # -----------
    pacman-install ca-certificates shadow
ADD_REPOS

# ---------------
# build-arg
ARG TESTING=false
RUN <<ENABLE_TESTING
#!/opt/bin/zsh
set -fexo pipefail
    if {! $TESTING} {
        exit
    }
    cfg=${DISABLED_DIR}/10-testing.conf
    mv ${cfg}.ini $cfg ||:
    cp -Lvf $cfg ${REPO_DIR} ||:
    pacman -Syu --noconfirm
ENABLE_TESTING

# ---------------
# build-arg
ARG BASE=false
RUN <<INSTALL_BASE
#!/opt/bin/zsh
set -fexo pipefail
    if {! $BASE} {
        exit
    }

    pacman-install base
    localedef --force --charmap=UTF-8 --inputfile=C C.UTF-8 ||:

    cd ${DISABLED_DIR}
    local -A cfg_map=(
        cn   90-archlinux-cn.conf
        edu  80-arch4edu.conf
    )
    for k v (${(kv)cfg_map}) {
        mv ${v}.ini $v || {
            cfg_map[$k]=false
            continue
        }
        cfg_map[$k]=true
    }

    for i (${DISABLED_DIR}/*.conf) {
        cp -Lvf $i ${REPO_DIR}
    }
    enable_pgp_check=true
    pacman-key --init || enable_pgp_check=false

    if {! $enable_pgp_check} {
        exit
    }

    case ${OS_ARCH} {
        (i686 | i486 | pentium4) keyring_name=archlinux32 ;;
        (aarch64 | arm*)
            pacman-install archlinuxarm-keyring
            keyring_name=archlinuxarm
        ;;
        (*) keyring_name=archlinux ;;
    }
    pacman-key --populate $keyring_name || enable_pgp_check=false

    if {$cfg_map[cn]} {
        pacman-key --lsign-key "farseerfc@archlinux.org" ||:
        pacman-install archlinuxcn-keyring archlinuxcn-mirrorlist-git ||:
    }

    if {$cfg_map[edu]} {
        pacman-key --recv-keys 7931B6D628C8D3BA
        pacman-key --finger 7931B6D628C8D3BA
        pacman-key --lsign-key 7931B6D628C8D3BA ||：
        pacman-install arch4edu/mirrorlist.arch4edu  arch4edu/arch4edu-keyring ||：
    }

    if {$enable_pgp_check} {
        cd ${OPTIONS_DIR}
        ln -svf bak/siglevel-optional.conf ./sig-level.conf
        unlink ../no-pgp-note.txt
    }
INSTALL_BASE

# ---------------
ARG BASE_DEV=false
RUN <<INSTALL_BASE_DEV
#!/opt/bin/zsh
set -fexo pipefail
    if {! $BASE_DEV} {
        exit
    }
    pacman-install base-devel
    pacman-install paru ||:
    useradd -m user
    usermod -aG wheel user
    wheel_sudoer=/etc/sudoers.d/wheel
    echo '%wheel ALL=(ALL:ALL) NOPASSWD: ALL' > $wheel_sudoer
    chmod 440 -v $wheel_sudoer
INSTALL_BASE_DEV
# ---------------
ARG ARCHIVE=false
RUN <<UPDATE_ARCHIVE
#!/opt/bin/zsh
set -fexo pipefail
    # archive
    case ${TMM_ARCH} {
        (x64*|i*86|x86) use_archive_cfg=true  ;;
        (*)             use_archive_cfg=false ;;
    }
    if ! {$ARCHIVE && $use_archive_cfg} {
        exit
    }

    pacman-install curl

    get_date() {
        local awk_cmd=(
            awk
            -F 'href='
            '/<a/ {
                html = $2
            } END {
                split(html, arr, "\"")
                date = arr[2]
                print date
            }'
        )
        curl -L $1 | $awk_cmd
    }

    cd ${REPO_DIR}
    rm *.conf ||:
    cp -Lvf ${DISABLED_DIR}/00-arch.conf .

    year=$(date +%Y)
    case ${OS_ARCH} {
        # https://arch-archive.tuna.tsinghua.edu.cn/
        ( x86_64 | x64v*)         url=https://archive.archlinux.org/repos/$year/   ;;
        ( i686 | i486 | pentium4) url=https://archive.archlinux32.org/repos/$year/ ;;
    }
    month=$(get_date $url)

    url=${url}${month}
    day=$(get_date $url)
    awk -v date="$year-$month-$day" 'BEGIN {
        gsub("/", "", date)
        print date
    }' > /opt/info/archive.txt

    case ${OS_ARCH} {
        (x86_64 | x64v*)         url="${url}${day}"'$repo/os/$arch' ;;
        (i686 | i486 | pentium4) url="${url}${day}"'$arch/$repo'    ;;
    }
    print >&2 $url

    cat > 20-archive.conf <<-ARCHIVE_CONF
[core]
Server = $url
[extra]
Server = $url
ARCHIVE_CONF

    /opt/pack -Sy
UPDATE_ARCHIVE

RUN <<CLEAN
#!/opt/bin/zsh
set -fex
    pacman_scc() {
        yes | /opt/pack -Scc ||:
    }

    # remove pacman-static & busybox-ash for non-x64
    case ${TMM_ARCH} {
        (x64*)
            pacman_scc
            rm -fv /opt/pack ||:
            /opt/bin/pacman --version ||:
        ;;
        (*)
            pacman-install pacman
            pacman_scc
            cd /opt/bin
            rm -fv /opt/pack ||:
            rm -fv pacman ||:
            rm -fv pacman-*static ||:
        ;;
    }

    rm -fv   /*.core  ||:
    rm -fv   /root/.* ||:

    rm -rfv  /var/cache/pacman/pkg/*                 ||:
    rm -rfv  /var/lib/pacman/sync/*                  ||:
    rm -rfv  /var/tmp/*                              ||:
    rm -rfv  /alpm-hooks                             ||:
    rm -rfv  /etc/pacman.d/gnupg/openpgp-revocs.d/*  ||:
    rm -rfv  /etc/pacman.d/gnupg/private-keys-v1.d/* ||:
    rm -rfv  /etc/pacman.d/gnupg/pubring.gpg~        ||:
    rm -rfv  /etc/pacman.d/gnupg/S.*                 ||:
    rm -rfv  /root/*                                 ||:
CLEAN

# ------------------------
# SHELL [ "/bin/bash", "-c" ]
# SHELL ["zsh", "--pipefail", "-fexc"]
ARG OPT=/opt/bin/
ENV LANG=C.UTF-8
COPY --from=zsh-tmm-arch ${OPT}busybox ${OPT}zsh ${OPT}
CMD [ "bash" ]
