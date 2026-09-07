# Kanata one-shot modifiers

This package provides one-shot modifiers for laptop keyboards on macOS and
Debian 13 with Sway. The external Keychron V3 Max ANSI and Q3 ANSI knob
keyboards will eventually get the same behaviour in QMK; their setup notes
are in `qmk/README.md` in this dotfiles checkout. Copy that file to
`~/Repos/qmk/README.md` if you want the notes alongside the firmware checkout.

Stow makes the configuration available. It does not install Kanata, grant
device permissions, or start a service.

## Behaviour

| Physical key | Tap and release | Hold |
| --- | --- | --- |
| Caps Lock or left Control | One-shot left Control | Left Control |
| Left Shift | One-shot left Shift | Left Shift |
| Right Shift | One-shot right Shift | Right Shift |
| Left Alt / Option | One-shot left Alt | Left Alt |
| Left GUI / Command / Super | One-shot left GUI | Left GUI |
| Right Control | One-shot right Control | Right Control |

Right Alt remains ordinary so the Linux us(altgr-intl) layout continues to
work. Other keys retain their normal keycodes. The timeout is 1000 ms and
different one-shot modifiers can be combined.

one-shot-release keeps the modifier active until the following key is
released. Holding the one-shot key itself still behaves like a normal held
modifier. The configuration has no repeated-tap locking.

## Enable the package

From the dotfiles checkout:

    cd ~/.dotfiles
    stow --simulate --verbose --target="$HOME" kanata
    stow --target="$HOME" kanata

Resolve an existing-file conflict before the second command. Do not use
Stow's --adopt option here.

Validate before starting Kanata:

    kanata --check --cfg ~/.config/kanata/kanata.kbd

During a foreground test, hold physical left Control + Space + Escape to exit
Kanata. The emergency chord is read before remapping.

## macOS

Install the stable Kanata formula:

    brew install kanata
    kanata --version

### Install and activate the driver

For Kanata 1.12.0, install the `.pkg` from the
[VirtualHIDDevice 6.2.0 release](https://github.com/pqrs-org/Karabiner-DriverKit-VirtualHIDDevice/releases/tag/v6.2.0).
Driver releases can change the communication protocol; check Kanata's
compatibility requirements before upgrading either component.

Activate the installed driver:

```sh
sudo /Applications/.Karabiner-VirtualHIDDevice-Manager.app/Contents/MacOS/Karabiner-VirtualHIDDevice-Manager forceActivate
```

In **System Settings > General > Login Items & Extensions > Driver
Extensions**, enable `org.pqrs.Karabiner-DriverKit-VirtualHIDDevice`.
Run `systemextensionsctl list` and check that its entry says
`[activated enabled]`. The extension's own version number can differ from
the installer package version.

### Grant permissions

Under **System Settings > Privacy & Security**, enable Kanata in both:

- **Input Monitoring**: permits reading keyboard input.
- **Device Control and Data Access** on macOS 27, called **Accessibility**
  on earlier releases: permits controlling applications and accessing their
  data. Kanata and macOS logs still call this permission Accessibility.

To add Kanata, click **+**, press **Command-Shift-G**, enter
`/opt/homebrew/bin/`, select `kanata`, and enable it. This is a symlink to the
installed Homebrew binary. Determine its actual target with:

```sh
ls -l /opt/homebrew/bin/kanata
```

If selecting the symlink does not work, select the executable at that target
instead. After upgrades, remove and re-add the entry if its approval no longer
matches the executable.

When running Kanata from Kitty, macOS can check **Kitty's** permissions as the
responsible application. Enable `/Applications/kitty.app` in both lists for
foreground testing, then fully quit Kitty with **Command-Q** and reopen it.
This extends those permissions to processes attributed to Kitty. A system
service runs independently of Kitty, so Kanata itself also needs approval.
`--macos-request-permissions` requests Accessibility only and may be attributed
to the terminal; it does not grant either permission automatically.

### Install the boot services

Two root services are required with the standalone driver package:

- `org.pqrs.Karabiner-VirtualHIDDevice-Daemon` supplies the virtual keyboard.
- `dev.kanata.kanata` reads the physical keyboard and performs the remapping.

If Karabiner-Elements already manages the VirtualHIDDevice daemon, skip the
standalone daemon's installation and start commands below. Do not run two
copies. Stop any foreground Kanata test with physical **left Control + Space
+ Escape** before starting the service.

The supplied property-list files (`.plist`) are in
`.config/kanata/launchd/`. They target Marc's Apple Silicon Mac:
`/opt/homebrew/bin/kanata` and `/Users/marc/.config/kanata/kanata.kbd`.
On another Mac, adjust these absolute paths first. `launchd` does not expand
`~` or `$HOME` inside a plist. The home-directory config is editable through
Stow; keep it and the executable writable only by trusted accounts because
the service runs as root.

Run the following in a terminal after stowing the package. These commands
install root-owned copies; subsequent plist edits require reinstalling them.

```sh
cd ~/.dotfiles/kanata/.config/kanata/launchd
/opt/homebrew/bin/kanata --check --cfg "$HOME/.config/kanata/kanata.kbd"
plutil -lint dev.kanata.kanata.plist org.pqrs.Karabiner-VirtualHIDDevice-Daemon.plist

sudo install -o root -g wheel -m 0644 org.pqrs.Karabiner-VirtualHIDDevice-Daemon.plist /Library/LaunchDaemons/org.pqrs.Karabiner-VirtualHIDDevice-Daemon.plist
sudo install -o root -g wheel -m 0644 dev.kanata.kanata.plist /Library/LaunchDaemons/dev.kanata.kanata.plist

sudo launchctl enable system/org.pqrs.Karabiner-VirtualHIDDevice-Daemon
sudo launchctl enable system/dev.kanata.kanata
sudo launchctl bootstrap system /Library/LaunchDaemons/org.pqrs.Karabiner-VirtualHIDDevice-Daemon.plist
sudo launchctl bootstrap system /Library/LaunchDaemons/dev.kanata.kanata.plist
```

Only continue after validation succeeds. `bootstrap` registers and starts
each service now; placing its plist in `/Library/LaunchDaemons` with
`RunAtLoad` makes it start on subsequent boots. On a repeat installation,
unload an already registered service with the corresponding `bootout` command
below before running `bootstrap` again.

Both services run as root because the VirtualHIDDevice communication socket
is restricted to root. Kanata uses `--no-wait` so an error cannot leave it
waiting for terminal input. It restarts after failures, but a successful
emergency exit leaves it stopped. The virtual-keyboard daemon is kept running.
Kanata reconnects if the helper starts later or restarts.

`--release-grab-on-lock` leaves keyboards unmodified while the screen is
locked or another user has the console. FileVault's pre-boot unlock screen
cannot use these services. A keyboard configuration stored in the home
directory also requires that directory to be available.

### Verify, restart, and recover

```sh
sudo launchctl print system/org.pqrs.Karabiner-VirtualHIDDevice-Daemon
sudo launchctl print system/dev.kanata.kanata
sudo tail -n 40 /var/log/karabiner-vhid-daemon.log /var/log/kanata.log
```

Both jobs should show `state = running`. Kanata must connect to its output
backend and process input without repeated permission or connection errors.
Test a one-shot modifier in a text editor. Repeat these checks after a reboot
and login; a registered service alone does not prove remapping works.

- `connect_failed asio.system:2`: Kanata cannot reach the helper's socket.
  Check the VirtualHIDDevice daemon's status and log; driver activation alone
  does not start this helper.
- Permission denied: check the relevant list above. Foreground launches may
  be attributed to Kitty, while the root service needs Kanata's own grant.
  Remove and re-add the affected entry if toggling it does not take effect,
  then restart that process.
- `Bootstrap failed: 5`: first check `launchctl print` for an already loaded
  job. If it is absent, check the plist with `plutil -lint`, its executable
  paths, and ownership (`root:wheel`, mode `0644`).

After editing the keyboard configuration, validate it and restart Kanata:

```sh
/opt/homebrew/bin/kanata --check --cfg "$HOME/.config/kanata/kanata.kbd" && sudo launchctl kickstart -k system/dev.kanata.kanata
```

To stop remapping until you start it again or reboot:

```sh
sudo launchctl bootout system/dev.kanata.kanata
```

To disable both services across reboots, without deleting the configuration:

```sh
sudo launchctl disable system/dev.kanata.kanata
sudo launchctl disable system/org.pqrs.Karabiner-VirtualHIDDevice-Daemon
sudo launchctl bootout system/dev.kanata.kanata
sudo launchctl bootout system/org.pqrs.Karabiner-VirtualHIDDevice-Daemon
```

An already unloaded job reports that it cannot be found. To restore startup,
run the `enable` and `bootstrap` commands from the installation section.
After changing a plist, reinstall its root-owned copy, `bootout` the loaded
job, then `bootstrap` it again; `kickstart` alone does not reload a plist.

Sources: [Kanata macOS setup](https://github.com/jtroo/kanata/blob/v1.12.0/docs/setup-macos.md),
[Kanata service](https://github.com/jtroo/kanata/blob/v1.12.0/cfg_samples/kanata.plist),
[VirtualHIDDevice service](https://github.com/jtroo/kanata/blob/v1.12.0/cfg_samples/karabiner-vhid-daemon.plist).
The macOS 27 permission label was checked in the installed System Settings
resources; the underlying permission is `kTCCServiceAccessibility`.

## Debian 13 and Sway

Install a stable upstream Kanata release matching the machine architecture
and verify its published SHA-256 checksum. Install the ordinary binary,
without cmd_allowed support, as /usr/local/bin/kanata:

    sudo install -m 0755 kanata_linux_x64 /usr/local/bin/kanata
    /usr/local/bin/kanata --version

Kanata needs read access to /dev/input and write access to /dev/uinput.
Create the uinput group if it does not exist, add the account to both input
and uinput, load the module, and install the udev rule described in the
upstream Linux setup at
https://github.com/jtroo/kanata/blob/v1.12.0/docs/setup-linux.md:

    getent group uinput || sudo groupadd --system uinput
    sudo usermod -aG input,uinput "$USER"
    sudo modprobe uinput

The udev rule is:

    KERNEL=="uinput", MODE="0660", GROUP="uinput", OPTIONS+="static_node=uinput"

Log out and back in after changing groups. Then validate and test in the
foreground:

    kanata --check --cfg ~/.config/kanata/kanata.kbd
    kanata --cfg ~/.config/kanata/kanata.kbd

Once that works, install a user service at ~/.config/systemd/user/kanata.service:

    [Unit]
    Description=Kanata keyboard remapper
    Documentation=https://github.com/jtroo/kanata

    [Service]
    Type=simple
    ExecStart=/usr/local/bin/kanata --cfg %h/.config/kanata/kanata.kbd --no-wait
    Restart=on-failure
    RestartSec=3

    [Install]
    WantedBy=default.target

Enable it with:

    systemctl --user daemon-reload
    systemctl --user enable --now kanata.service
    systemctl --user status kanata.service

This starts after login, not at the graphical login screen. Access to the
input group lets the account read keyboard input, so use a more restricted
device-specific service if that tradeoff is unacceptable.

## Transition to QMK

Initially Kanata processes all detected keyboards. After each Keychron has
working QMK firmware, restrict Kanata to the internal keyboard with exact
device include lists. Get names with kanata --list on macOS and from
Kanata's registering lines on Linux. Add both options to the same defcfg,
replacing the examples:

    (defcfg
      process-unmapped-keys yes
      linux-dev-names-include ("EXACT LINUX INTERNAL KEYBOARD NAME")
      macos-dev-names-include ("EXACT MACOS INTERNAL KEYBOARD NAME")
    )

Restart Kanata after changing device filters. Live reload does not change
which devices are grabbed.

Your Sway configuration still contains
caps:ctrl_modifier,altwin:swap_lalt_lwin. Kanata emits actual Control for
Caps; the existing XKB setting remains a fallback when Kanata is stopped.
The Alt/GUI swap also affects Kanata's virtual output, so verify the result
with wev. Disable native Sticky Keys while testing so two latching systems do
not interact.

## Verification

Test one-shot Control, Shift, Alt and GUI separately, then test combinations,
timeouts, repeated held modifiers, AltGr accents, Sway bindings, tmux
Control-Space, Emacs shortcuts, sleep/unlock and USB/Bluetooth reconnects.
Over SSH, remapping happens on the local keyboard host; nothing needs to be
installed on the remote server.

No firmware is flashed by this package. Review the files before stowing them.
