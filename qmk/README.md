# Keychron QMK notes

The two external keyboards are:

- Keychron V3 Max ANSI, QWERTY, 80%
- Keychron Q3 ANSI with knob, QWERTY, 80%

Their firmware targets in the Keychron `2025q3` branch are:

    keychron/v3_max/ansi_encoder
    keychron/q3/ansi_encoder

Confirm both names with `qmk list-keyboards` after cloning the Keychron QMK
repository.

## Build environment

Keep this ordinary Git repository under ~/Repos, outside Nextcloud. QMK can
be installed on either macOS or Debian; the resulting firmware works with
both operating systems.

macOS:

    brew tap osx-cross/avr
    brew tap qmk/qmk
    brew trust --tap osx-cross/avr
    brew trust --tap qmk/qmk
    brew install qmk/qmk/qmk
    qmk --version
    qmk doctor

Debian 13:

    sudo apt update
    sudo apt install --no-install-recommends ca-certificates curl git ripgrep
    curl -fsSL https://install.qmk.fm -o /tmp/install-qmk.sh
    less /tmp/install-qmk.sh
    sh /tmp/install-qmk.sh
    qmk --version
    qmk doctor

QMK's official bootstrapper installs the CLI, compiler toolchains and
flashing utilities. The current setup guide is at
https://docs.qmk.fm/newbs_getting_started. Do not run the whole build as root.

Clone this personal repository and the Keychron fork's `2025q3` branch, then
copy the tracked keymaps into the vendor checkout:

    git clone git@github.com:marcschlienger/qmk.git ~/Repos/qmk
    cd ~/Repos/qmk
    git clone --branch 2025q3 --recurse-submodules https://github.com/Keychron/qmk_firmware.git keychron-qmk
    cd keychron-qmk
    qmk setup -H "$PWD"
    cp -R ../keymaps/keychron/v3_max/ansi_encoder/marc keyboards/keychron/v3_max/ansi_encoder/keymaps/
    cp -R ../keymaps/keychron/q3/ansi_encoder/marc keyboards/keychron/q3/ansi_encoder/keymaps/
    qmk doctor
    qmk list-keyboards | rg '^keychron/(v3_max|q3)/'

For an existing checkout, update the branch and submodules, then restore the
personal keymaps from their repository:

    cd ~/Repos/qmk/keychron-qmk
    git status --short
    git fetch origin 2025q3
    git switch 2025q3
    git pull --ff-only origin 2025q3
    git submodule update --init --recursive
    qmk setup -H "$PWD"
    cp -R ../keymaps/keychron/v3_max/ansi_encoder/marc keyboards/keychron/v3_max/ansi_encoder/keymaps/
    cp -R ../keymaps/keychron/q3/ansi_encoder/marc keyboards/keychron/q3/ansi_encoder/keymaps/
    qmk doctor

Install QMK's Debian udev rules from this checkout so flashing does not
require running the whole build as root:

    sudo util/install_udev.sh
    sudo udevadm control --reload-rules
    sudo udevadm trigger

Reconnect the keyboard after installing the rules. Check the exact targets
before compiling:

    qmk list-keyboards | rg '^keychron/(v3_max|q3)/'

Sources:

- https://github.com/Keychron/qmk_firmware
- https://docs.qmk.fm/newbs_getting_started
- https://docs.qmk.fm/faq_build#linux-udev-rules

## Keymap

Compile an unchanged default keymap for each exact target before editing:

    qmk compile -kb keychron/v3_max/ansi_encoder -km default
    qmk compile -kb keychron/q3/ansi_encoder -km default

Inspect the available keymap directories before copying one:

    ls keyboards/keychron/v3_max/ansi_encoder/keymaps
    ls keyboards/keychron/q3/ansi_encoder/keymaps

Preserve each model's existing Mac and Windows/Linux layers, encoder
behaviour, wireless controls and lighting settings. Add a personal keymap
directory rather than replacing the whole model keymap.

The intended one-shot mapping matches the Kanata package. The bottom row is:

    Alt  Super  Control  Space  Control  Super  Right-Alt  Fn

Fn moves to the far-right physical key. Right Alt remains ordinary for the
Linux us(altgr-intl) layout; the other listed modifiers are one-shot keys.
Both Mac and Windows/Linux base layers emit the same final layout because
Sway does not reorder modifiers.

| Physical key | Tap and release | Hold |
| --- | --- | --- |
| Caps Lock | One-shot left Control | Left Control |
| Left outer modifier | One-shot left Alt | Left Alt |
| Left middle modifier | One-shot left GUI | Left GUI |
| Left inner modifier | One-shot left Control | Left Control |
| Left Shift | One-shot left Shift | Left Shift |
| Right Shift | One-shot right Shift | Right Shift |
| Right inner modifier | One-shot right Control | Right Control |
| Right middle modifier | One-shot right GUI | Right GUI |
| Right outer modifier | Right Alt | Right Alt |
| Far-right modifier | Fn layer | Fn layer |

Use these QMK keycodes in both relevant base layers:

    OSM(MOD_LCTL)
    OSM(MOD_LSFT)
    OSM(MOD_RSFT)
    OSM(MOD_LALT)
    OSM(MOD_LGUI)
    OSM(MOD_RCTL)
    OSM(MOD_RGUI)

QMK's GUI is Command on macOS and usually Super on Linux; it is not Emacs
Meta, which is normally Alt/Option.

In the personal keymap's config.h, merge these definitions with any existing
settings:

    #pragma once
    #define ONESHOT_TIMEOUT 1000

Do not define `ONESHOT_TAP_TOGGLE`; leaving it undefined disables repeated-tap
locking in this QMK tree. Do not add `NO_ACTION_ONESHOT`. See
https://docs.qmk.fm/one_shot_keys.

## Flashing

Before flashing, export the current VIA or Launcher layout. The personal QMK
repository contains the downloaded factory firmware recovery files:

| File | SHA-256 |
| --- | --- |
| `q3_us_knob_v1.7.bin` | `473ea336a92a1ec7276987224f5191fde1cd1f19ea5115c7f6468c8e2a1d255b` |
| `v3_max_ansi_encoder_v1.1.1_2504221453.bin` | `76ec00981771818ba72d666c1b93259cccdd4b3cde6916691fe5d0674a5eb595` |

A layout JSON is not a firmware backup. Replacement factory images are
published at https://www.keychron.com/pages/firmware.

Build the personal keymap:

    qmk compile -kb keychron/v3_max/ansi_encoder -km marc
    qmk compile -kb keychron/q3/ansi_encoder -km marc

The Keychron build emits a `VIA_INSECURE is enabled` warning because these
keymaps preserve the keyboards' VIA support. It is not a compiler failure,
but VIA-capable host software is part of the trust boundary; use only trusted
firmware and configuration tools.

For each keyboard separately:

1. Confirm that Kanata excludes it.
2. Disconnect the other Keychron. Both expose the same generic STM32 DFU
   identity, so the flasher cannot distinguish the models in bootloader mode.
3. Set the selected keyboard to Cable mode and connect it directly by USB.
4. Run the matching flash command:

       qmk flash -kb keychron/v3_max/ansi_encoder -km marc
       qmk flash -kb keychron/q3/ansi_encoder -km marc

5. When the command waits for the bootloader, unplug the keyboard, hold
   Escape, reconnect it, and release Escape after about two seconds. The reset
   button below the space bar is the alternative.
6. Keep the USB cable connected until `dfu-util` reports
   `File downloaded successfully` and the command exits successfully.

VIA can retain an older dynamic keymap across a firmware flash. If the new
layout is not active, hold Fn + J + Z for about four seconds to reset the
stored layout. In the `marc` keymap, Fn is the far-right physical key. During
the first migration, the old layout may still put Fn on the key labelled Fn;
try that position if the new one does not trigger the reset. A V3 Max factory
reset can require Bluetooth devices to be paired again.

Do not flash Bluetooth, receiver or other radio firmware merely to change a
keymap. Test the encoder, wireless modes, both Mac/Windows switch positions,
ordinary key repeat and one-shot behaviour after flashing.

QMK's general flashing guide is at https://docs.qmk.fm/flashing.

## Kanata transition

Kanata processes the internal laptop keyboards while the Keychrons implement
the layout in QMK. The macOS include list and Linux Keychron exclusions are in
the Kanata defcfg. Confirm the exact Linux device names before enabling its
service. The configuration and platform service instructions are in
the Dotfiles repository's `kanata/README.md`.

Do not run QMK and Kanata on the same Keychron at the same time: both would
apply one-shot state. Verify that the Keychrons still work when Kanata is
stopped and that the laptop keyboard still works when the Keychrons are
disconnected.

No firmware is flashed by these notes. The vendor checkout is disposable;
keep the personal keymaps and recovery firmware in the personal QMK
repository.
