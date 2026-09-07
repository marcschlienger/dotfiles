# Keychron QMK notes

The two external keyboards are:

- Keychron V3 Max ANSI, QWERTY, 80%
- Keychron Q3 ANSI with knob, QWERTY, 80%

Their firmware targets are expected to be:

    keychron/v3_max/ansi_encoder
    keychron/q3/ansi_encoder

Confirm both names with qmk list-keyboards after cloning the Keychron QMK
repository. The V3 Max definition has historically been published in
Keychron's wireless_playground branch, while Q3 is present in the QMK
Keychron tree. Do not assume that one branch contains both targets; inspect
the checkout and use the branch that actually contains each target.

## Build environment

Keep this ordinary Git repository under ~/Repos, outside Nextcloud. QMK can
be installed on either macOS or Debian; the resulting firmware works with
both operating systems.

macOS:

    brew install qmk/qmk/qmk
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

Clone the Keychron fork's branch that contains both of these targets. The
branch used for this setup is `2025q3`:

    mkdir -p ~/Repos/qmk
    cd ~/Repos/qmk
    git clone --branch 2025q3 --recurse-submodules https://github.com/Keychron/qmk_firmware.git keychron-qmk
    cd keychron-qmk
    qmk setup -H "$PWD"
    qmk doctor
    qmk list-keyboards | rg '^keychron/(v3_max|q3)/'

For an existing checkout, update the branch and submodules without discarding
local keymaps:

    cd ~/Repos/qmk/keychron-qmk
    git status --short
    git fetch origin 2025q3
    git switch 2025q3
    git pull --ff-only origin 2025q3
    git submodule update --init --recursive
    qmk setup -H "$PWD"
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

The intended one-shot mapping matches the Kanata package:

| Physical key | Tap and release | Hold |
| --- | --- | --- |
| Caps Lock or left Control | One-shot left Control | Left Control |
| Left Shift | One-shot left Shift | Left Shift |
| Right Shift | One-shot right Shift | Right Shift |
| Left Alt / Option | One-shot left Alt | Left Alt |
| Left GUI / Command / Super | One-shot left GUI | Left GUI |
| Right Control | One-shot right Control | Right Control |

Use these QMK keycodes in both relevant base layers:

    OSM(MOD_LCTL)
    OSM(MOD_LSFT)
    OSM(MOD_RSFT)
    OSM(MOD_LALT)
    OSM(MOD_LGUI)
    OSM(MOD_RCTL)

Leave right Alt ordinary for the Linux us(altgr-intl) layout. QMK's GUI is
Command on macOS and usually Super on Linux; it is not Emacs Meta, which is
normally Alt/Option.

In the personal keymap's config.h, merge these definitions with any existing
settings:

    #pragma once
    #define ONESHOT_TIMEOUT 1000
    #define ONESHOT_TAP_TOGGLE 0

The second setting disables repeated-tap locking. Do not add
NO_ACTION_ONESHOT. See https://docs.qmk.fm/one_shot_keys.

## Flashing

Before flashing, export the current VIA or Launcher layout and download the
exact factory firmware for each keyboard from
https://www.keychron.com/pages/firmware. A layout JSON is not a firmware
backup.

Build the personal keymap:

    qmk compile -kb keychron/v3_max/ansi_encoder -km marc
    qmk compile -kb keychron/q3/ansi_encoder -km marc

For each keyboard separately:

1. Stop Kanata, or configure it to exclude that keyboard.
2. Set the keyboard to Cable mode and connect it directly by USB.
3. Enter the bootloader using the reset procedure for that exact model and
   wait for the operating system to detect it.
4. Run the matching flash command:

       qmk flash -kb keychron/v3_max/ansi_encoder -km marc
       qmk flash -kb keychron/q3/ansi_encoder -km marc

5. Keep the USB cable connected until flashing completes.

For the V3 Max, the documented reset procedure is holding Escape or the
reset button below the space bar while connecting USB in Cable mode. Use the
Q3's own model instructions for its reset procedure.

Do not flash Bluetooth, receiver or other radio firmware merely to change a
keymap. Test the encoder, wireless modes, both Mac/Windows switch positions,
ordinary key repeat and one-shot behaviour after flashing.

QMK's general flashing guide is at https://docs.qmk.fm/flashing.

## Kanata transition

Kanata initially processes all detected keyboards so the layout can be
tested on the laptop and Keychrons. Once each Keychron works independently
with QMK, add exact internal-keyboard include names to the Kanata defcfg and
restart Kanata. The configuration and platform service instructions are in
../kanata/README.md.

Do not run QMK and Kanata on the same Keychron at the same time: both would
apply one-shot state. Verify that the Keychrons still work when Kanata is
stopped and that the laptop keyboard still works when the Keychrons are
disconnected.

No firmware is flashed by these notes. Keep the QMK checkout and each
personal keymap under version control, and record the source revision used
for every successful build.
