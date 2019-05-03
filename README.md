# Linux Surface + Linux CK

See https://github.com/jakeday/linux-surface for the original `linux-surface` README, and https://aur.archlinux.org/packages/linux-ck/ for the Arch User Repo's page for `linux-ck`.

This repo contains linux kernel 5.x patches (jakeday's original work) but diff'd against the `linux-ck` patchset. It is meant to be used as part of an Arch kernel build. These patches might work with other distros but I haven't tested them, and kernel 4.x is unsupported.

These are _only_ the patches and the kernel config file -- see jakeday's repo for firmware, useful shell scripts and instructions; see `linux-ck` for the stuff needed to get an Arch build going, and see https://wiki.archlinux.org/index.php/Kernel for info on how Arch manages its kernels.

This is a work in progress and might leave your machine in a bad state. I make no guarantees.
