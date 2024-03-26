---
markmap:
  embedAssets: true
  maxWidth: 300
---

# arch &emsp;

## x64 &emsp;

- platform: linux/amd64 &emsp;
- os-arch: x86_64 &emsp;

## x64v2 &emsp;

- platform: linux/amd64/v2 &emsp;
- os-arch: x86_64 &emsp;
- description &emsp;
  - feature level matches the 2008 Intel Nehalem &emsp;
  - AMD Bulldozer and newer AMD "big" cores &emsp;
  - <https://somegit.dev/ALHP/ALHP.GO>

## x64v3 &emsp;

- platform: linux/amd64/v3 &emsp;
- os-arch: x86_64 &emsp;
- description &emsp;
  - feature level matches the 2013 Intel Haswell &emsp;
  - AMD Excavator and newer AMD "big" cores &emsp;

## x64v4 &emsp;

- platform &emsp;
  - linux/amd64/v3 &emsp;
  - linux/amd64/v4 &emsp;
- os-arch: x86_64 &emsp;
- description &emsp;
  - feature level matches the 2017 Intel Skylake-X &emsp;
  - AMD Zen 4 cores &emsp;

## rv64gc &emsp;

- platform: linux/riscv64 &emsp;
- os-arch: riscv64 &emsp;
- description:
  - RISC-V 64-Bit &emsp;
  - IMAFDC &emsp;
  - <https://riscv.mirror.pkgbuild.com/>

## arm64 &emsp;

- platform: linux/arm64 &emsp;
- os-arch: aarch64 &emsp;
- description: <https://archlinuxarm.org/platforms/armv8>

## armv7a &emsp;

- platform: linux/arm/v7 &emsp;
- os-arch: armv7h &emsp;
- features: +vfp3, -d32, +thumb2 &emsp;

## loong64 &emsp;

- platform: linux/loong64 &emsp;
- os-arch: loong64 &emsp;
- description: <https://loongarchlinux.org/>

## x86 &emsp;

- platform: linux/386 &emsp;
- os-arch: pentium4 &emsp;
- description: <https://archlinux32.org/architecture/>

## i686 &emsp;

- platform: linux/386 &emsp;
- os-arch: i686 &emsp;

## i486 &emsp;

- platform: linux/386 &emsp;
- os-arch: i486 &emsp;

## ppc64le &emsp;

- platform: linux/ppc64le &emsp;
- os-arch: powerpc64le &emsp;
- description: <https://archlinuxpower.org/>

## ppc64 &emsp;

- platform: linux/ppc64 &emsp;
- os-arch: powerpc64 &emsp;

## ppc &emsp;

- platform: linux/ppc &emsp;
- os-arch: powerpc &emsp;
