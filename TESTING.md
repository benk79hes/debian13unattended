# Testing Guide

This guide helps you test the Debian Trixie unattended installer.

## Pre-build Validation

### 1. Validate Preseed Configuration

```bash
./validate-preseed.sh
```

This checks that all required preseed settings are present.

### 2. Check File Permissions

```bash
ls -la build-installer.sh additional-scripts/*.sh validate-preseed.sh
```

All scripts should be executable (have `x` permission).

## Build Testing

### 1. Build the Docker Image

```bash
make build
# or
docker build -t debian-trixie-installer .
```

Expected: Should complete without errors.

### 2. Inspect the Image

```bash
docker images | grep debian-trixie-installer
```

Expected: Should show the built image.

## ISO Creation Testing

### Full Build Test

```bash
# This will take 5-10 minutes and download ~400MB
make run
```

Expected output:
- ISO download progress
- Mounting and copying messages
- "ISO created successfully" message
- File appears in `output/debian-trixie-unattended.iso`

### Verify ISO

```bash
ls -lh output/debian-trixie-unattended.iso
file output/debian-trixie-unattended.iso
```

Expected:
- File size: ~400-600MB
- File type: ISO 9660 CD-ROM filesystem

## Installation Testing

### Option 1: VirtualBox

1. Create new VM:
   - Type: Linux
   - Version: Debian (64-bit)
   - RAM: 1024MB minimum
   - Disk: 8GB minimum

2. Attach ISO:
   - Settings > Storage > Controller: IDE > Add optical drive
   - Select `output/debian-trixie-unattended.iso`

3. Start VM and observe:
   - Boot menu appears
   - "Automated Install" option selected automatically
   - Installation begins without interaction
   - System reboots automatically when done

4. Test installation:
   ```bash
   # Login as root with password: root
   cat /etc/debian_version  # Should show trixie/sid or 13.x
   ls -la /root/additional-scripts/  # Should contain example.sh
   systemctl status ssh  # Should be active
   grep PermitRootLogin /etc/ssh/sshd_config  # Should show "yes"
   locale  # Should show en_US.UTF-8
   cat /etc/timezone  # Should show Europe/Zurich
   ```

### Option 2: QEMU

```bash
# Create a test disk
qemu-img create -f qcow2 test-disk.qcow2 10G

# Run installation (headless)
qemu-system-x86_64 \
  -cdrom output/debian-trixie-unattended.iso \
  -hda test-disk.qcow2 \
  -m 2048 \
  -boot d \
  -nographic

# Or with graphics
qemu-system-x86_64 \
  -cdrom output/debian-trixie-unattended.iso \
  -hda test-disk.qcow2 \
  -m 2048 \
  -boot d
```

### Option 3: VMware

1. Create new VM with Debian 11 x64 template
2. Attach ISO to CD/DVD
3. Configure boot order to boot from CD
4. Start VM
5. Verify installation proceeds automatically

## Automated Testing Checklist

After installation completes, verify:

- [ ] System boots to login prompt
- [ ] Can login as root (password: root)
- [ ] Can login as debian user (password: debian)
- [ ] Locale is en_US.UTF-8: `locale`
- [ ] Timezone is Europe/Zurich: `cat /etc/timezone`
- [ ] SSH is running: `systemctl status ssh`
- [ ] SSH allows root login: `grep PermitRootLogin /etc/ssh/sshd_config`
- [ ] No desktop environment installed: `which gdm3 || echo "No desktop"`
- [ ] Standard tools present: `which vim nano less`
- [ ] Additional scripts present: `ls /root/additional-scripts/`
- [ ] Network configured: `ip a`
- [ ] Disk fully partitioned: `df -h`

## Common Issues

### Build fails with "Permission denied"

**Solution**: Run with `--privileged` flag:
```bash
docker run --rm --privileged -v $(pwd)/output:/output debian-trixie-installer
```

### ISO download very slow

**Solution**: The first build downloads ~400MB. Use a mirror closer to you by editing `build-installer.sh`:
```bash
ISO_URL="https://YOUR-CLOSER-MIRROR/debian-testing-amd64-netinst.iso"
```

### Installation hangs at "Configuring apt"

**Cause**: Network connectivity issue  
**Solution**: Ensure VM has network access (NAT mode in VirtualBox)

### "No operating system found" after installation

**Cause**: GRUB not installed correctly  
**Solution**: Check BIOS/UEFI settings, ensure boot order correct

## Performance Benchmarks

Typical times (may vary based on hardware/network):

- Docker image build: 2-5 minutes
- ISO download: 5-10 minutes (first time)
- ISO creation: 2-3 minutes
- Installation: 10-20 minutes

Total first-time run: ~20-30 minutes

## Debugging

### Enable verbose output

Edit `build-installer.sh` and add at the top:
```bash
set -x  # Enable debug mode
```

### Check Docker logs

```bash
docker logs <container-id>
```

### Interactive debugging

```bash
docker run -it --rm --privileged \
  -v $(pwd)/output:/output \
  debian-trixie-installer /bin/bash

# Then manually run:
/build/build-installer.sh
```

## Continuous Integration

For CI/CD pipelines, you can automate testing:

```yaml
# Example GitHub Actions
- name: Build installer
  run: make build

- name: Create ISO
  run: make run

- name: Verify ISO
  run: |
    test -f output/debian-trixie-unattended.iso
    SIZE=$(stat -f%z output/debian-trixie-unattended.iso || stat -c%s output/debian-trixie-unattended.iso)
    test $SIZE -gt 300000000  # At least 300MB
```

## Next Steps

Once testing is complete:

1. Customize `preseed.cfg` for your needs
2. Add your scripts to `additional-scripts/`
3. Update passwords in preseed.cfg
4. Rebuild and retest
5. Deploy to production

## Support

For issues or questions:
- Check the main [README.md](README.md)
- Review [QUICKSTART.md](QUICKSTART.md)
- Inspect preseed.cfg comments
- Review Debian preseed documentation
