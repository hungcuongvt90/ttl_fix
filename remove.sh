#!/system/bin/sh
# Written by Zibri (Zibri @ GitHub)

MAGISKBOOT="magiskboot"

err() {
	echo -e "\e[94m[!] $@\e[39m"
        sleep 10
	exit 1
}

[[ ! -f "$MAGISKBOOT" ]] && err "Failed to find magiskboot binary. Exiting."

rm -rf /data/local/tmp/ttl_fix
SLOT=`getprop ro.boot.slot_suffix`
BOOT="boot$SLOT"
BOOTIMG="/dev/block/by-name/$BOOT"

mkdir -p /data/local/tmp/ttl_fix
cd /data/local/tmp/ttl_fix

dd if="$BOOTIMG" of="/data/local/tmp/ttl_fix/boot.img" conv=notrunc
$MAGISKBOOT unpack -h "/data/local/tmp/ttl_fix/boot.img"
( $MAGISKBOOT hexpatch kernel 1F2003D51F2003D568F24039E8002836 C9220039C816007968F24039E8002836 || # Redmi Note 10 pro
$MAGISKBOOT hexpatch kernel 1F2003D5A0224039000400511F2003D5 A0160079A022403900040051A0220039 || # REVVL 6 Pro
$MAGISKBOOT hexpatch kernel 080500111F2003D51F2003D5687A4079 08050011C9220039C8160079687A4079 || # pixel6a
$MAGISKBOOT hexpatch kernel 1F2003D51F2003D568F24039 C8160079C922003968F24039 # Asus Rog 6
) && (
$MAGISKBOOT repack "/data/local/tmp/ttl_fix/boot.img" new.img
dd if=new.img of="$BOOTIMG" conv=notrunc
mv /data/local/tmp/ttl_fix/boot.img /sdcard/boot.img.backup
rm -rf /data/local/tmp/ttl_fix
echo -e "\e[94m[!] $@\e[39mPatch removed."
sync;sleep 5;reboot
) || err "Patch not removed."

