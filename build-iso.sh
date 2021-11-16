#!/bin/sh

set -e -x

if ! [ $# -eq 3 ]; then
    echo "usage: <src-iso> <dst-iso> <volume-id>" >&2
    exit 1
fi

SOURCE_ISO="$1"
TARGET_ISO="$2"
VOLUME_ID="$3"

# prepare working directory
rm -rf _iso
mkdir -p _iso

# extract iso
7z x "${SOURCE_ISO}" -o_iso

# copy _iso/custom/
cp -r custom _iso

# replace _iso/boot/grub/grub.cfg, if content match
diff _iso/boot/grub/grub.cfg - <<EOF

if loadfont /boot/grub/font.pf2 ; then
	set gfxmode=auto
	insmod efi_gop
	insmod efi_uga
	insmod gfxterm
	terminal_output gfxterm
fi

set menu_color_normal=white/black
set menu_color_highlight=black/light-gray

set timeout=5
menuentry "Install Ubuntu Server" {
	set gfxpayload=keep
	linux	/casper/vmlinuz   quiet  ---
	initrd	/casper/initrd
}
menuentry "Install Ubuntu Server (safe graphics)" {
	set gfxpayload=keep
	linux	/casper/vmlinuz   quiet  nomodeset ---
	initrd	/casper/initrd
}
grub_platform
if [ "\$grub_platform" = "efi" ]; then
menuentry 'Boot from next volume' {
	exit
}
menuentry 'UEFI Firmware Settings' {
	fwsetup
}
fi
EOF
cat >_iso/boot/grub/grub.cfg <<EOF
if loadfont /boot/grub/font.pf2 ; then
	set gfxmode=auto
	insmod efi_gop
	insmod efi_uga
	insmod gfxterm
	terminal_output gfxterm
fi

set menu_color_normal=white/black
set menu_color_highlight=black/light-gray

set timeout=1
menuentry "Install Iquana" {
	set gfxpayload=keep
	linux   /casper/vmlinuz   quiet net.ifnames=0 biosdevname=0 autoinstall ds=nocloud\\;s=/cdrom/custom/ ---
	initrd  /casper/initrd
}
menuentry "Install Iquana (safe graphics)" {
	set gfxpayload=keep
	linux   /casper/vmlinuz   quiet  nomodeset net.ifnames=0 biosdevname=0 autoinstall ds=nocloud\\;s=/cdrom/custom/ ---
	initrd  /casper/initrd
}
grub_platform
if [ "\$grub_platform" = "efi" ]; then
menuentry 'Boot from next volume' {
	exit
}
menuentry 'UEFI Firmware Settings' {
	fwsetup
}
fi
EOF

# replace _iso/isolinux/txt.cfg, if content match
diff _iso/isolinux/txt.cfg - <<EOF
default live
label live
  menu label ^Install Ubuntu Server
  kernel /casper/vmlinuz
  append   initrd=/casper/initrd quiet  ---
label live-nomodeset
  menu label ^Install Ubuntu Server (safe graphics)
  kernel /casper/vmlinuz
  append   initrd=/casper/initrd quiet  nomodeset ---
label memtest
  menu label Test ^memory
  kernel /install/mt86plus
label hd
  menu label ^Boot from first hard disk
  localboot 0x80
EOF
cat >_iso/isolinux/txt.cfg <<EOF
default live
label live
  menu label ^Install Iquana
  kernel /casper/vmlinuz
  append   initrd=/casper/initrd quiet net.ifnames=0 biosdevname=0 autoinstall ds=nocloud;s=/cdrom/custom/ ---
label live-nomodeset
  menu label ^Install Iquana (safe graphics)
  kernel /casper/vmlinuz
  append   initrd=/casper/initrd quiet nomodeset net.ifnames=0 biosdevname=0 autoinstall ds=nocloud;s=/cdrom/custom/ ---
label memtest
  menu label Test ^memory
  kernel /install/mt86plus
label hd
  menu label ^Boot from first hard disk
  localboot 0x80
EOF

# skip md5sum check
md5sum _iso/README.diskdefines > _iso/md5sum.txt
sed -i 's|_iso/|./|g' _iso/md5sum.txt

# create iso
xorriso -as mkisofs -r \
  -V "$VOLUME_ID" \
  -o "$TARGET_ISO" \
  -J -l -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot \
  -boot-load-size 4 -boot-info-table \
  -eltorito-alt-boot -e boot/grub/efi.img -no-emul-boot \
  -isohybrid-gpt-basdat -isohybrid-apm-hfsplus \
  -isohybrid-mbr /usr/lib/ISOLINUX/isohdpfx.bin  \
  _iso/boot _iso
