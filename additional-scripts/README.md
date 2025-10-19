# Additional Installation Scripts

This directory contains scripts that will be copied to `/root/additional-scripts/` on the installed Debian system.

You can add your custom post-installation scripts here. They will be available on the installed system for manual execution or automation.

## Usage

1. Add your shell scripts to this directory
2. Make them executable: `chmod +x your-script.sh`
3. Rebuild the Docker image
4. The scripts will be available in `/root/additional-scripts/` after installation

## Example

See `example.sh` for a template script that demonstrates common post-installation tasks.
