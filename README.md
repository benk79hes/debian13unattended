# Debian Trixie (13) Unattended Installer

A Docker-based solution for creating a customized Debian Trixie (Debian 13) unattended installation ISO.

## Features

This automated installer includes:

- **Language**: English (en_US.UTF-8)
- **Country**: Switzerland (CH)
- **Keyboard Layout**: Swiss French (ch-fr)
- **Partitioning**: Automatic full disk partitioning
- **Desktop Environment**: None (server installation)
- **Packages**: Standard system utilities and SSH server
- **SSH Configuration**: PermitRootLogin enabled (set to `yes`)
- **Additional Scripts**: Support for custom post-installation scripts

## Requirements

- Docker installed on your system
- Sufficient disk space (~2GB for building)
- Internet connection to download Debian ISO

## Quick Start

### 1. Build the Docker Image

```bash
docker build -t debian-trixie-installer .
```

### 2. Create the Unattended ISO

Run the Docker container to build the custom ISO:

```bash
docker run --rm --privileged \
  -v $(pwd)/output:/output \
  debian-trixie-installer
```

The ISO will be created in the `output/` directory as `debian-trixie-unattended.iso`.

### 3. Use the ISO

You can now use the generated ISO to:
- Boot from a USB drive (use tools like `dd`, Rufus, or Etcher to write to USB)
- Boot in a virtual machine (VirtualBox, VMware, QEMU, etc.)
- Deploy on physical hardware

The installation will start automatically after 10 seconds.

## Default Credentials

⚠️ **Warning**: Change these default credentials for production use!

- **Root password**: `root`
- **User**: `debian` / Password: `debian`

## Customization

### Modify Preseed Configuration

Edit `preseed.cfg` to customize:
- Passwords (use `mkpasswd -m sha-512` to generate encrypted passwords)
- Hostname and domain
- Package selection
- Partitioning scheme
- Time zone
- And more...

### Add Custom Scripts

Place your custom post-installation scripts in the `additional-scripts/` directory. These scripts will be copied to `/root/additional-scripts/` on the installed system.

Example:
```bash
cp my-custom-script.sh additional-scripts/
chmod +x additional-scripts/my-custom-script.sh
```

Then rebuild the Docker image.

### Keyboard Layouts

The current configuration uses Swiss French keyboard (ch-fr). To change:

Edit `preseed.cfg` and modify:
```
d-i keyboard-configuration/xkb-keymap select ch(fr)
```

Common alternatives:
- US: `us`
- UK: `gb`
- German (Switzerland): `ch(de)`
- French (France): `fr`

## Directory Structure

```
.
├── Dockerfile                 # Docker image definition
├── preseed.cfg               # Debian preseed configuration
├── build-installer.sh        # ISO building script
├── additional-scripts/       # Custom post-installation scripts
│   ├── README.md
│   └── example.sh
├── .dockerignore            # Docker ignore file
└── README.md                # This file
```

## Configuration Details

### Localization
- **Locale**: en_US.UTF-8
- **Language**: English
- **Country**: Switzerland
- **Timezone**: Europe/Zurich

### Partitioning
- Uses the entire first disk (`/dev/sda`)
- Atomic partitioning recipe (one partition for everything)
- Automatically confirms all partitioning decisions

### Network
- Automatic network configuration via DHCP
- Default hostname: `debian-trixie`
- Default domain: `localdomain`

### Packages
- Standard system utilities
- SSH server (OpenSSH)
- sudo

### SSH Configuration
- Root login enabled with password authentication
- SSH service enabled on boot

## Advanced Usage

### Building with Custom Output Directory

```bash
mkdir -p /path/to/output
docker run --rm --privileged \
  -v /path/to/output:/output \
  debian-trixie-installer
```

### Interactive Build (for debugging)

```bash
docker run -it --rm --privileged \
  -v $(pwd)/output:/output \
  debian-trixie-installer /bin/bash
```

Then manually run:
```bash
/build/build-installer.sh
```

## Security Notes

⚠️ **Important Security Considerations**:

1. **Change Default Passwords**: The preseed uses default passwords for demonstration. Always change these before production use.

2. **Root Login**: SSH root login is enabled for convenience. Consider disabling it after initial setup or using SSH keys only.

3. **Network Security**: The system uses DHCP by default. Configure static IPs and firewall rules as needed.

4. **Update Regularly**: Keep the system updated with security patches:
   ```bash
   apt-get update && apt-get upgrade -y
   ```

## Troubleshooting

### ISO Not Booting
- Ensure the ISO was written correctly to USB/VM
- Try using different USB writing tools
- Check BIOS/UEFI boot settings

### Build Fails
- Ensure you have sufficient disk space
- Check internet connectivity for ISO download
- Run with `--privileged` flag for mounting operations

### Installation Hangs
- Check network connectivity (needed for package downloads)
- Review preseed configuration syntax
- Boot in expert mode and check system logs

## License

This project is provided as-is for educational and deployment purposes.

## Contributing

Feel free to submit issues or pull requests for improvements.