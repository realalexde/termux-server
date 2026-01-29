#!/system/bin/sh
# Minimal Mint + XFCE + TigerVNC installer for Android root
set -e
CHROOT=/data/local/chroot/mint
TARBALL=/data/local/tmp/ubuntu-base-arm64.tar.gz
URL=https://cdimage.ubuntu.com/ubuntu-base/releases/22.04/release/ubuntu-base-22.04.5-base-arm64.tar.gz
USER=mint
PASS=mint
VNC_DISP=:1
mkdir -p $CHROOT /data/local/tmp
[ ! -f $TARBALL ] && wget -O $TARBALL $URL
[ ! -f $CHROOT/bin/bash ] && tar -xzf $TARBALL -C $CHROOT && mkdir -p $CHROOT/{dev,proc,sys,run,tmp} && chmod 1777 $CHROOT/tmp
cp /etc/resolv.conf $CHROOT/etc/resolv.conf
mount --bind /dev $CHROOT/dev || true
mount --bind /dev/pts $CHROOT/dev/pts || true
mount -t proc proc $CHROOT/proc || true
mount -t sysfs sys $CHROOT/sys || true
run() { chroot $CHROOT /bin/bash -c "$*"; }
echo "deb http://archive.ubuntu.com/ubuntu/ jammy main universe multiverse" > $CHROOT/etc/apt/sources.list
run "apt-get update -y"
run "DEBIAN_FRONTEND=noninteractive apt-get install -y sudo dbus-x11 x11-xserver-utils xterm xinit xfce4 xfce4-goodies tigervnc-standalone-server"
run "id -u $USER || (useradd -m -s /bin/bash $USER && echo '$USER:$PASS' | chpasswd && adduser $USER sudo)"
run "mkdir -p /home/$USER/.vnc && echo '#!/bin/sh\nunset SESSION_MANAGER\nunset DBUS_SESSION_BUS_ADDRESS\nexec dbus-run-session startxfce4' > /home/$USER/.vnc/xstartup && chmod +x /home/$USER/.vnc/xstartup && chown -R $USER:$USER /home/$USER/.vnc"
echo -e "#!/system/bin/sh\nmount --bind /dev $CHROOT/dev\nmount --bind /dev/pts $CHROOT/dev/pts\nmount -t proc proc $CHROOT/proc\nmount -t sysfs sys $CHROOT/sys\nchroot $CHROOT /home/$USER/.vnc/xstartup" > /data/local/chroot/start-xfce.sh
chmod +x /data/local/chroot/start-xfce.sh
echo "Installation done. Start with: sh /data/local/chroot/start-xfce.sh, connect via VNC on display $VNC_DISP, default user/pass: $USER/$PASS"
