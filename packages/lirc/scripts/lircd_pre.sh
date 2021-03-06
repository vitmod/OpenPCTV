#!/bin/sh

/bin/mkdir -p /var/run/lirc

TMPFILE=/tmp/TMP.$$

/bin/mkdir -p /var/run/lirc
if [ -f /etc/lirc/hardware.conf ]; then
   source /etc/lirc/hardware.conf
else
   exit 1
fi

default_ir ()
{
for i in 0 1 2 3 4 5 6 7 8 9; do
  [ -d /sys/class/rc ] && break
  sleep 0.3
done

for i in 0 1 2 3 4 5 6 7 8 9; do
  if test -r /dev/lirc0 || ls /sys/class/rc/* >/dev/null 2>&1; then
     break
  fi
  sleep 0.3
done

FIRSTIR="yes"
if [ X$DRV_NAME = Xlirc_rpi ]; then
  DEVEVENT2=lirc0
  FIRSTIR="no"
fi

for i in /sys/class/rc/*; do
  [ $FIRSTIR == "yes" ] && DEVEVENT2=$(ls -d $i/lirc*)
  grep -i "$DRV_NAME" $i/uevent >/dev/null 2>&1 && DEVEVENT1=$(ls -d $i/lirc*)
  FIRSTIR="no"
done

if [ "X$DEVEVENT1" == "X" ]; then
  DEVEVENT=$(basename ${DEVEVENT2})
else
  DEVEVENT=$(basename ${DEVEVENT1})
fi

if [ "X$DEVEVENT" == "X" ]; then
  DEVEVENT=lirc0
fi

DEVICE="/dev/$DEVEVENT"

DEVNUM=${DEVEVENT##*lirc}
if [ -f /sys/class/rc/rc${DEVNUM}/protocols ]; then
  echo "lirc" > /sys/class/rc/rc${DEVNUM}/protocols
fi
}

devinput_ir ()
{
DEVICE="/dev/input/by-id/$DRV_NAME"
}

if [ $DRIVER = default ]; then
  default_ir
elif [ $DRIVER = devinput ]; then
  devinput_ir
else
  exit
fi

sed -i "s#^DEVICE=.*#DEVICE=\"$DEVICE\"#g" /etc/lirc/hardware.conf
