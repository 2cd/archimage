---
markmap:
  embedAssets: true
  maxWidth: 300
---

# arch

## x64

- platform: linux/amd64
- os-arch: x86_64

## x64v2

- platform: linux/amd64/v2
- os-arch: x86_64
- description
  - feature level matches the 2008 Intel Nehalem
  - AMD Bulldozer and newer AMD "big" cores
  - <https://somegit.dev/ALHP/ALHP.GO>

## x64v3

- platform: linux/amd64/v3
- os-arch: x86_64
- description
  - feature level matches the 2013 Intel Haswell
  - AMD Excavator and newer AMD "big" cores

## x64v4

- platform
  - linux/amd64/v3
  - linux/amd64/v4
- os-arch: x86_64
- description
  - feature level matches the 2017 Intel Skylake-X
  - AMD Zen 4 cores

## rv64gc

- platform: linux/riscv64
- os-arch: riscv64
- description:
  - RISC-V 64-Bit
  - IMAFDC
  - <https://riscv.mirror.pkgbuild.com/>

## arm64

- platform: linux/arm64
- os-arch: aarch64
- description: <https://archlinuxarm.org/platforms/armv8>

## armv7a

- platform: linux/arm/v7
- os-arch: armv7h
- features: +vfp3, -d32, +thumb2

## loong64

- platform: linux/loong64
- os-arch: loong64
- description: <https://loongarchlinux.org/>

## x86

- platform: linux/386
- os-arch: pentium4
- description: <https://archlinux32.org/architecture/>

## i686

- platform: linux/386
- os-arch: i686

## i486

- platform: linux/386
- os-arch: i486

## ppc64le

- platform: linux/ppc64le
- os-arch: powerpc64le
- description: <https://archlinuxpower.org/>

## ppc64

- platform: linux/ppc64
- os-arch: powerpc64

## ppc

- platform: linux/ppc
- os-arch: powerpc
