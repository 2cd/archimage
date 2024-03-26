---
markmap:
  embedAssets: true
---

# Images

## arch

- No <span style="color: Orange;">base</span> included
- Only contains essential software packages

## arch-slim

- i18n data other than <span style="color: DarkCyan;">en_*</span> is not included
- Does not include **man** manual data
- cfg: <span style="color: DarkCyan;">[options].NoExtract</span>

## arch-base

- Includes <span style="color: Orange;">base</span> installation
- Enables **archlinuxcn** and **arch4edu** repositories

## arch-dev

- Includes everything in **arch-base**
- Includes <span style="color: Orange;">base-dev</span>
- Includes <span style="color: Orange;">paru</span>
- Presets user
  - name: user
  - uid: 1000
  - groups
    - user (1000)
    - wheel (998)

## arch-testing

- Enables **core-testing** and **extra-testing** repositories

## arch-archive

- Non-rolling release
- Uses repositories with fixed date
- e.g., <archive.archlinux.org/repos/2024/03/25/>

## pacman-static

- Contains only pacman, busybox, and zsh
- Can be used as the smallest ArchLinux
