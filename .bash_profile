#!/data/data/com.termux/files/usr/bin/env bash

# Set Termux default file permission.
umask 022

# Manually modify system settings here.
ROOTFS="${ROOTFS:-http://os.archlinuxarm.org/os/ArchLinuxARM-aarch64-latest.tar.gz}"
PACKAGES="${PACKAGES:-pulseaudio chromium x11vnc xorg-server-xvfb novnc websockify python-numpy tree ttf-droid}"
TIMEZONE="${TIMEZONE:-America/New_York}"
LOCALE="${LOCALE:-en_US}"
USERNAME="${USERNAME:-guest}"
PASSWORD="${PASSWORD:-Defaults:$USERNAME !authenticate}"
DISTRO="${DISTRO:-archlinux}"

# Termux dependencies to install.
DEPENDS=(proot-distro pulseaudio)
if ! dpkg -s ${DEPENDS[@]} &> /dev/null ; then
  echo "[•] Install missing dependencies..."
  yes | pkg update && \
  yes | pkg install ${DEPENDS[@]}
fi

# Rootfs initial setup.
if [[ ! -d "$PREFIX/var/lib/proot-distro/installed-rootfs/$DISTRO" ]]; then
  if [[ ! -f "$PREFIX/var/lib/proot-distro/dlcache/${ROOTFS##*/}" ]]; then
    echo "[•] Fetch rootfs and update sources..."
    curl -L -C - "$ROOTFS" -o $PREFIX/var/lib/proot-distro/dlcache/${ROOTFS##*/}
    sed -i -E "s|(TARBALL_URL\['aarch64'\]=).*|\1$ROOTFS|" $PREFIX/etc/proot-distro/$DISTRO.sh
    sed -i -E "s|(TARBALL_SHA256\['aarch64'\]=).*|\1$(sha256sum $PREFIX/var/lib/proot-distro/dlcache/${ROOTFS##*/} | awk '{print $1}')|" $PREFIX/etc/proot-distro/$DISTRO.sh
  fi
  echo "[•] Install rootfs and prepare for initial setup..."
  proot-distro install $DISTRO
  echo "[•] Copy existing dotfiles/overlays/packages..."
  [[ -d dotfiles ]] && cp -a dotfiles "$TMPDIR"
  [[ -d overlays ]] && cp -a overlays "$TMPDIR"
  [[ -d packages ]] && cp -a packages "$TMPDIR"
  # NOTE: Custom packages like fakeroot-tcp produces an error upon
  # compiling when not logged in to chroot environment, so we use a
  # bash profile script to run the rest of commands inside chroot.
cat << ... > "$PREFIX/var/lib/proot-distro/installed-rootfs/$DISTRO/root/.bash_profile"
  echo "[•] Set system locale and time zone..."
  rm -f /etc/localtime && ln -s /usr/share/zoneinfo/$TIMEZONE /etc/localtime
  sed -i '/^#$LOCALE.UTF-8/s/^#//' /etc/locale.gen && locale-gen
  printf '%s\n' 'LANG=$LOCALE.UTF-8' > /etc/locale.conf
  echo "[•] Remove unecessary large packages..."
  pacman -Rnss --noconfirm linux-aarch64 linux-firmware
  echo "[•] Initialize pacman keyring..."
  pacman-key --init && pacman-key --populate archlinuxarm
  echo "[•] Install/update core packages..."
  pacman -Syu --noconfirm base base-devel man-db man-pages openssh git
  echo "[•] Create new user and set sudo access..."
  useradd -m -k /tmp/dotfiles -c ${USERNAME^} $USERNAME
  [[ "$PASSWORD" != "Defaults:$USERNAME !authenticate" ]] && echo "$USERNAME:$PASSWORD" | chpasswd
  printf '%s\n' '$USERNAME ALL=(ALL) ALL' '$PASSWORD' > /etc/sudoers.d/custom
  echo "[•] Installing fakeroot with tcp/ipc support..."
  mkdir -p /tmp/fakeroot-tcp && cd /tmp/fakeroot-tcp
  curl -Lo- "http://ftp.debian.org/debian/pool/main/f/fakeroot/fakeroot_1.27.orig.tar.gz" | bsdtar -xkf - --strip 1
  ./bootstrap && ./configure --prefix=/usr --libdir=/usr/lib --disable-static --with-ipc=tcp && make && make install
  echo "[•] Install packages using Trizen AUR helper..."
  git clone https://aur.archlinux.org/trizen.git /tmp/trizen
  cd /tmp/trizen && su -c 'makepkg -si --noconfirm' $USERNAME
  su -c 'trizen -Syu --noconfirm ${PACKAGES[@]}' $USERNAME
  echo "[•] Build existing custom packages with makepkg..."
  for package in /tmp/packages/*; do
    if [[ -d "$package" ]]; then
      cd $package
      su -c 'makepkg -si --noconfirm' $USERNAME
    fi
  done
  echo "[•] Copy overlay system files..."
  [[ -d /tmp/overlays ]] && cp -a /tmp/overlays/. /
  echo "[•] Clean up and exit initial setup..."
  su -c 'yes | trizen -Scc' $USERNAME
  rm -f /root/.bash_profile
  echo "[•] Please restart Termux..."
  exit
...

  exec proot-distro login --shared-tmp $DISTRO
fi

# Enable PulseAudio sound streaming.
pactl load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1 > /dev/null

proot-distro login --shared-tmp --user $USERNAME $DISTRO ${@}
