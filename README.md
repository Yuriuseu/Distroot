# Distroot

Termux distro chroot environment.

## Installation

Download the files to Termux home directory, then relaunch the app:

```bash
curl -Lo- https://github.com/Yuriuseu/Distroot/tarball/main | tar -xzf - --exclude='README.md' --strip 1
```

> **Note**: Modify the global variables declared in [bash_profile](./.bash_profile) before restarting Termux.
>
> To uninstall, simply run:
>
> ```bash
> chmod -R 777 $DIRECTORY
> rm -rf $DIRECTORY
> ```
>
> Set `$DIRECTORY` to rootfs install directory.

> **Note**: The script is specific to Arch Linux but can be configured for other distribution.

## Configuration

To change the general defaults, modify the [bash_profile](./.bash_profile) global variables:

- [**$ROOTFS**](https://archlinuxarm.org/platforms/armv8/generic): Arch Linux AArch64 archive download URL.
- [**$PACKAGES**](https://archlinux.org/packages/): Packages to install (including [AUR](https://aur.archlinux.org/) packages).
- [**$TIMEZONE**](https://wiki.archlinux.org/title/System_time#Time_zone): Default local time zone.
- [**$LOCALE**](https://wiki.archlinux.org/title/locale): Default system language.
- **$NAMESERVER**: Required name server for network access (default: 8.8.8.8).
- **$USERNAME**: Required user account (default: guest).
- **$PASSWORD**: User account password (blank by default, using `!authenticate` for `sudo` access).
- **$DIRECTORY**: Rootfs install directory (default: ~/.termux/linux).

User-specific files and custom packages:

- [**dotfiles/**](./dotfiles): Contains user-specific configuration files. This will be copied to created user's home directory.
- [**packages/**](./packages): Contains custom packages to be built and installed with `makepkg`. This will be copied to `$TMPDIR` directory.

> **Note**: These folders will be deleted after initial setup. Requires a backup of these files.

### Manual startup

The `bash_profile` will automatically start replacing Termux shell environment. To manually start, rename it with something esle like `distroot.sh`. If done this way, script can be configured by declaring the variables directly without modifying it. E.g:

```bash
USERNAME=coolname
DIRECTORY=~/distroot
./distroot.sh
```

### Using `proot-distro`

It's possible to use `proot-distro`, but it requires a few modifications to the script:

1. Replace `distroot()` function with:

```bash
distroot() {
  proot-distro --shared-tmp --login --user $USERNAME archlinux
}
```

2. Ignore `$ROOTFS` variable and replace `$DEPENDS` variable in dependencies section with:

```bash
DEPENDS=(proot-distro pulseaudio)
```

3. Remove or comment out the install command in setup section and replace with:

```bash
#mkdir -p "$DIRECTORY" && curl -Lo - "$ROOTFS" | proot -l bsdtar -xpkf - -C "$DIRECTORY"
proot-distro install archlinux
```

> **Note**: Further configuration requires heavy modifications.

## X server and VNC

Default setup uses [X11VNC](https://wiki.archlinux.org/title/x11vnc) and [noVNC](https://novnc.com/). The [xlaunch](./dotfiles/.local/bin/xlaunch) script is used to start the Desktop Environment manually. By default, it launches the custom [dwm](./packages/dwm) window manager. To start a different DE or WM like XFCE:

```bash
exec xlaunch dbus-launch --exit-with-session startxfce4
```

Then access the desktop in the browser: [`localhost:6080/vnc.html`](http://localhost:6080/vnc.html).

> **Note**: This doesn't require a password to connect. To setup a password, change the `-nopw` flag of `x11vnc` to `-usepw`, then run `x11vnc -usepw` first before `xlaunch`.

### Audio access and X server speed

Audio streaming is enabled using PulseAudio but noVNC has no audio access by default. If audio and/or speed is a must, use [RealVNC](https://www.realvnc.com/) or [XSDL](https://github.com/pelya/xserver-xsdl) instead.

- For RealVNC app, just connect to `localhost:5900`.
- For XSDL app, make sure the app is running first, then run the program(s) directly in Termux (no additional setup/commands required).
