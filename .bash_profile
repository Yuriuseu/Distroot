#!/data/data/com.termux/files/usr/bin/env bash

# Set Termux default file permission
umask 022

# IMPORTANT: Manually modify system settings here.
ROOTFS="${ARCHIVE:-http://os.archlinuxarm.org/os/ArchLinuxARM-aarch64-latest.tar.gz}"
PACKAGES="${PACKAGES:-pulseaudio chromium x11vnc xorg-server-xvfb novnc websockify python-numpy tree ttf-droid}"
TIMEZONE="${TIMEZONE:-America/New_York}"
LOCALE="${LOCALE:-en_US}"
NAMESERVER="${NAMESERVER:-8.8.8.8}"
USERNAME="${USERNAME:-guest}"
PASSWORD="${PASSWORD:-Defaults:$USERNAME !authenticate}"
DIRECTORY="${DIRECTORY:-$HOME/.termux/linux}"

# Custom chroot function (see: proot --help).
distroot() {
  unset LD_PRELOAD
  proot -0 -l --kill-on-exit \
    -r "$DIRECTORY" \
    -w /root \
    -b /dev \
    -b "/dev/urandom:/dev/random" \
    -b /proc \
    -b "/proc/self/fd:/dev/fd" \
    -b "/proc/self/fd/0:/dev/stdin" \
    -b "/proc/self/fd/1:/dev/stdout" \
    -b "/proc/self/fd/2:/dev/stderr" \
    -b /sys \
    -b "$TMPDIR:/tmp" \
    -b "$DIRECTORY/tmp:/dev/shm" \
    /usr/bin/env -i \
      "TERM=$TERM" \
      $@
}

# Termux dependencies to install.
DEPENDS=(bsdtar proot pulseaudio)
if ! dpkg -s ${DEPENDS[@]} &> /dev/null ; then
  yes | pkg update && \
  yes | pkg install ${DEPENDS[@]}
fi

# One time rootfs setup.
if [[ ! -d "$DIRECTORY" ]] ; then
  # Install $ROOTFS to given $DIRECTORY
  mkdir -p "$DIRECTORY" && curl -Lo - "$ROOTFS" | proot -l bsdtar -xpkf - -C "$DIRECTORY"

  # Create a user to copy user-specific files, etc.
  distroot useradd -m -c ${USERNAME^} $USERNAME

  # Copy files from 'dotfiles' directory to user directory.
  [[ -d dotfiles ]] && cp -a dotfiles/. "$DIRECTORY/home/$USERNAME" && rm -rf dotfiles

  # Copy custom packages to /tmp to be built later using `makepkg`.
  [[ -d packages ]] && PKGBUILDS=($(ls -1 packages)) && cp -a packages/* "$TMPDIR" && rm -rf packages

  # Using a bash profile script to run the rest of setup commands inside chroot.
  # NOTE: For unknown reason, custom packages like fakeroot-tcp produces an error
  #   upon compiling when not logged in to chroot environment.
cat << ... > "$DIRECTORY/root/.bash_profile"
  # Symlink local time zone
  rm -f /etc/localtime && ln -s /usr/share/zoneinfo/$TIMEZONE /etc/localtime

  # Change default system locale
  sed -i '/^#$LOCALE.UTF-8/s/^#//' /etc/locale.gen && locale-gen
  printf '%s\n' 'LANG=$LOCALE.UTF-8' > /etc/locale.conf

  # Set name server for internet access
  rm -f /etc/resolv.conf && printf '%s\n' 'nameserver $NAMESERVER' > /etc/resolv.conf

  # Remove unecessary large packages not required inside chroot environment
  pacman -Rnss --noconfirm linux-aarch64 linux-firmware

  # IMPORTANT: Initialize `pacman` keyring before installing packages
  pacman-key --init && pacman-key --populate archlinuxarm

  # Install/update necessary core packages
  pacman -Syu --noconfirm base base-devel man-db man-pages openssh git

  # Set user password and `sudo` command access
  [[ "$PASSWORD" != "Defaults:$USERNAME !authenticate" ]] && echo "$USERNAME:$PASSWORD" | chpasswd
  printf '%s\n' '$USERNAME ALL=(ALL) ALL' '$PASSWORD' > /etc/sudoers.d/custom

  # Fakeroot fix where `makepkg` fails to build custom packages
  mkdir -p /tmp/fakeroot-tcp && cd /tmp/fakeroot-tcp
  curl -Lo- "http://ftp.debian.org/debian/pool/main/f/fakeroot/fakeroot_1.27.orig.tar.gz" | bsdtar -xkf - --strip 1
  ./bootstrap && ./configure --prefix=/usr --libdir=/usr/lib --disable-static --with-ipc=tcp && make && make install
 
  # Using an AUR helper to to handle AUR packages recursive dependencies
  git clone https://aur.archlinux.org/trizen.git /tmp/trizen
  cd /tmp/trizen && su -c 'makepkg -si --noconfirm' $USERNAME
  su -c 'trizen -Syu --noconfirm ${PACKAGES[@]}' $USERNAME

  # Build existing custom packages from /tmp with `makepkg`
  for package in ${PKGBUILDS[@]}; do cd /tmp/\$package && su -c 'makepkg -si --noconfirm' $USERNAME; done

  # Clean up and exit initial setup
  su -c 'yes | trizen -Scc' $USERNAME
  rm -f /root/.bash_profile && exit
...
  distroot su -
fi

# Enable PulseAudio sound streaming.
pactl load-module \
  module-native-protocol-tcp \
  auth-ip-acl=127.0.0.1 \
  auth-anonymous=1 > /dev/null

# Log in to chroot environment as user.
distroot ${@:-su - $USERNAME}
