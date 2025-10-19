# Quick Start Guide

## Build and Create ISO in 3 Steps

### Option 1: Using Make (Recommended)

```bash
# Build and create the ISO
make run

# The ISO will be in the output/ directory
ls -lh output/debian-trixie-unattended.iso
```

### Option 2: Using Docker Compose

```bash
# Build and create the ISO
docker-compose up --build

# The ISO will be in the output/ directory
ls -lh output/debian-trixie-unattended.iso
```

### Option 3: Using Docker Directly

```bash
# Build the image
docker build -t debian-trixie-installer .

# Create the ISO
mkdir -p output
docker run --rm --privileged \
  -v $(pwd)/output:/output \
  debian-trixie-installer

# Check the result
ls -lh output/debian-trixie-unattended.iso
```

## What's Included?

✅ **Language**: English  
✅ **Country**: Switzerland  
✅ **Keyboard**: Swiss French (ch-fr)  
✅ **Partitioning**: Automatic full disk  
✅ **Desktop**: None (server installation)  
✅ **Packages**: Standard tools + SSH  
✅ **SSH**: Root login enabled  
✅ **Scripts**: Additional scripts directory  

## Default Login

```
Root:  root / root
User:  debian / debian
```

⚠️ **Change these passwords in production!**

## Next Steps

1. **Write ISO to USB**:
   ```bash
   # Linux/macOS
   sudo dd if=output/debian-trixie-unattended.iso of=/dev/sdX bs=4M status=progress
   
   # Or use Rufus (Windows), Etcher (all platforms)
   ```

2. **Boot from USB/VM**:
   - The installation starts automatically after 1 second
   - No user interaction required
   - Installation takes 10-20 minutes

3. **Customize (optional)**:
   - Edit `preseed.cfg` for different settings
   - Add scripts to `additional-scripts/` directory
   - Rebuild: `make run`

## Customization Examples

### Change Password

Edit `preseed.cfg`:
```
d-i passwd/root-password password YourNewPassword
d-i passwd/root-password-again password YourNewPassword
```

### Add Custom Script

```bash
# Create your script
cat > additional-scripts/my-setup.sh << 'EOF'
#!/bin/bash
apt-get update
apt-get install -y vim htop
EOF

# Make it executable
chmod +x additional-scripts/my-setup.sh

# Rebuild
make run
```

The script will be available at `/root/additional-scripts/my-setup.sh` after installation.

## Troubleshooting

### Build fails
- Ensure Docker is running
- Check internet connection (for ISO download)
- Ensure enough disk space (~2GB)

### ISO doesn't boot
- Use `--privileged` flag when running Docker
- Verify USB write was successful
- Check BIOS/UEFI boot settings

## More Information

See the full [README.md](README.md) for detailed documentation.
