FROM debian:trixie-slim

# Install necessary tools for building the installer
RUN apt-get update && apt-get install -y \
    wget \
    xorriso \
    isolinux \
    syslinux-utils \
    rsync \
    genisoimage \
    && rm -rf /var/lib/apt/lists/*

# Create working directories
WORKDIR /build

# Create directory for additional scripts
RUN mkdir -p /build/additional-scripts

# Copy preseed configuration
COPY preseed.cfg /build/preseed.cfg

# Copy additional scripts directory
COPY additional-scripts/ /build/additional-scripts/

# Copy build script
COPY build-installer.sh /build/build-installer.sh
RUN chmod +x /build/build-installer.sh

# Default command
CMD ["/build/build-installer.sh"]
