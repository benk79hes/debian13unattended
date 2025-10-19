#!/bin/bash
# Validation script to check preseed configuration syntax

echo "Validating preseed configuration..."
echo ""

CONFIG_FILE="preseed.cfg"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ Error: preseed.cfg not found"
    exit 1
fi

# Check for required settings
echo "Checking required settings..."

required_settings=(
    "debian-installer/locale"
    "keyboard-configuration/xkb-keymap"
    "netcfg/get_hostname"
    "passwd/root-password"
    "mirror/http/hostname"
    "partman-auto/method"
    "tasksel/first"
    "grub-installer/only_debian"
)

missing=0
for setting in "${required_settings[@]}"; do
    if grep -q "$setting" "$CONFIG_FILE"; then
        echo "✅ Found: $setting"
    else
        echo "❌ Missing: $setting"
        missing=$((missing + 1))
    fi
done

echo ""
if [ $missing -eq 0 ]; then
    echo "✅ All required settings found"
    echo ""
    
    # Show key configuration values
    echo "Key configuration values:"
    echo "========================="
    grep -E "locale string|keyboard-configuration/xkb-keymap|time/zone|passwd/root-password[^-]|PermitRootLogin" "$CONFIG_FILE" | grep -v "^#"
    
    echo ""
    echo "✅ Preseed configuration appears valid"
    exit 0
else
    echo "❌ Missing $missing required settings"
    exit 1
fi
