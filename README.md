# Distroot

Termux distro chroot environment.

## Installation

Download the files to Termux home directory, then relaunch the app:

```bash
curl -Lo- https://github.com/Yuriuseu/Distroot/tarball/main | tar -xzf - --exclude='README.md' --strip 1
```

> **Note**: This will overwrite existing files. Add `-k` flag to `tar` command to avoid overwriting.

> **Note**: Modify the global variables declared in [`bash_profile`](./.bash_profile) before restarting Termux.

> **Note**: The script is specific to Arch Linux but can be configured for other distribution.

## Configuration

To change the general defaults, modify the [`bash_profile`](./.bash_profile) global variables:

- [`$ROOTFS`](https://archlinuxarm.org/platforms/armv8/generic): Arch Linux AArch64 archive download URL.
- [`$PACKAGES`](https://archlinux.org/packages/): Packages to install (including [AUR](https://aur.archlinux.org/) packages).
- [`$TIMEZONE`](https://wiki.archlinux.org/title/System_time#Time_zone): Local time zone (default: `America/New_York`).
- [`$LOCALE`](https://wiki.archlinux.org/title/locale): System language (default: `en_US`).
- `$USERNAME`: Required user account (default: `guest`).
- `$PASSWORD`: User account password (blank by default, using `!authenticate` for `sudo` access without password).
- `$DISTRO`: Rootfs install directory (default: `archlinux`).

System/user-specific files and custom packages:

- [`dotfiles/`](./dotfiles): Contains user-specific configuration files. This will be copied to created user's home directory.
- `overlays/`: Contains root-level system files. This will be copied to root (`/`) directory.
- [`packages/`](./packages): Contains custom packages to be built and installed with `makepkg`.

> **Note**: These folders will be moved to `$TMPDIR`. A backup of these folders is necessary.

> **Note**: Further configuration for other distro requires heavy modifications to the script.

### Manual startup

The `bash_profile` will automatically start replacing Termux shell environment. To manually start, rename it with something esle like `distroot.sh`. If done this way, script can be configured by declaring the variables directly without modifying it. E.g:

```bash
USERNAME=coolname
DIRECTORY=~/distroot
./distroot.sh
```

## GUI environment

Setup uses [X11VNC](https://wiki.archlinux.org/title/x11vnc) and [noVNC](https://novnc.com/). The [xlaunch](./dotfiles/.local/bin/xlaunch) script is used to start the Desktop Environment manually. By default, it launches the custom [dwm](./packages/dwm) window manager. To start a different WM or DE like XFCE:

```bash
exec xlaunch dbus-launch --exit-with-session startxfce4
```

Then access the desktop in the browser: [`localhost:6080/vnc.html`](http://localhost:6080/vnc.html).

> **Note**: This doesn't require a password to connect. See [X11VNC](https://wiki.archlinux.org/title/x11vnc) for more details.

> **Note**: See `man dwm` for DWM keyboard combinations.

### Audio access and speed

Audio streaming is enabled using PulseAudio but noVNC has no audio access by default. If audio and/or speed is a must, use [RealVNC](https://www.realvnc.com/) or [XSDL](https://github.com/pelya/xserver-xsdl) instead.

- For RealVNC app, just connect to `localhost:5900`.
- For XSDL app, make sure the app is running first, then run the program(s) directly in Termux (no additional setup/commands required).
