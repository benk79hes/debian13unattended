#!/bin/bash
set -e

echo "===================================="
echo "Debian Trixie Unattended Installer"
echo "===================================="

# Variables
# Using Trixie (testing) netinst ISO
ISO_URL="https://cdimage.debian.org/cdimage/weekly-builds/amd64/iso-cd/debian-testing-amd64-netinst.iso"
ISO_NAME="debian-netinst.iso"
OUTPUT_ISO="debian-trixie-unattended.iso"
WORK_DIR="/build/work"
MOUNT_DIR="/build/mount"

echo "Creating working directories..."
mkdir -p "$WORK_DIR"
mkdir -p "$MOUNT_DIR"

echo "Downloading Debian netinst ISO..."
if [ ! -f "/build/$ISO_NAME" ]; then
    wget -O "/build/$ISO_NAME" "$ISO_URL"
else
    echo "ISO already downloaded, skipping..."
fi

echo "Mounting ISO..."
mount -o loop "/build/$ISO_NAME" "$MOUNT_DIR"

echo "Copying ISO contents..."
rsync -av "$MOUNT_DIR/" "$WORK_DIR/"

echo "Unmounting ISO..."
umount "$MOUNT_DIR"

echo "Making working directory writable..."
chmod -R +w "$WORK_DIR"

echo "Copying preseed configuration..."
cp /build/preseed.cfg "$WORK_DIR/preseed.cfg"

echo "Copying additional scripts..."
mkdir -p "$WORK_DIR/additional-scripts"
if [ -d "/build/additional-scripts" ] && [ "$(ls -A /build/additional-scripts)" ]; then
    cp -r /build/additional-scripts/* "$WORK_DIR/additional-scripts/"
fi

echo "Modifying isolinux configuration for auto-install..."
cat > "$WORK_DIR/isolinux/txt.cfg" << 'EOF'
default auto
label auto
    menu label ^Automated Install
    kernel /install.amd/vmlinuz
    append auto=true priority=critical vga=788 initrd=/install.amd/initrd.gz preseed/file=/cdrom/preseed.cfg --- quiet
EOF

# Update isolinux.cfg timeout
sed -i 's/timeout 0/timeout 10/' "$WORK_DIR/isolinux/isolinux.cfg" || true

echo "Fixing MD5 checksums..."
cd "$WORK_DIR"
chmod +w md5sum.txt
find -follow -type f ! -name md5sum.txt -print0 | xargs -0 md5sum > md5sum.txt
chmod -w md5sum.txt

echo "Creating new ISO..."
cd /build
genisoimage -r -J -b isolinux/isolinux.bin \
    -c isolinux/boot.cat \
    -no-emul-boot -boot-load-size 4 -boot-info-table \
    -o "$OUTPUT_ISO" "$WORK_DIR"

# Make the ISO bootable
isohybrid "$OUTPUT_ISO" || echo "Warning: isohybrid not available, ISO may not be bootable on USB"

echo "===================================="
echo "ISO created successfully: $OUTPUT_ISO"
echo "===================================="

# Copy to output if mounted
if [ -d "/output" ]; then
    cp "$OUTPUT_ISO" "/output/"
    echo "ISO copied to /output/"
fi

echo "Done!"
