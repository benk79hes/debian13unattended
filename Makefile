.PHONY: build run clean help validate

# Variables
IMAGE_NAME=debian-trixie-installer
OUTPUT_DIR=./output

help:
	@echo "Debian Trixie Unattended Installer - Makefile"
	@echo ""
	@echo "Available targets:"
	@echo "  build       - Build the Docker image"
	@echo "  run         - Build the custom Debian ISO"
	@echo "  compose     - Build using docker-compose"
	@echo "  validate    - Validate preseed configuration"
	@echo "  clean       - Remove generated files and output"
	@echo "  clean-all   - Remove everything including Docker images"
	@echo "  help        - Show this help message"
	@echo ""
	@echo "Example usage:"
	@echo "  make validate && make build && make run"

validate:
	@echo "Validating preseed configuration..."
	@./validate-preseed.sh

build:
	@echo "Building Docker image..."
	docker build -t $(IMAGE_NAME) .

run: validate build
	@echo "Creating output directory..."
	@mkdir -p $(OUTPUT_DIR)
	@echo "Building Debian Trixie unattended installer ISO..."
	docker run --rm --privileged \
		-v $(PWD)/output:/output \
		$(IMAGE_NAME)
	@echo ""
	@echo "ISO created successfully in $(OUTPUT_DIR)/"

compose:
	@echo "Building with docker-compose..."
	@mkdir -p $(OUTPUT_DIR)
	docker-compose up --build

clean:
	@echo "Cleaning output directory..."
	rm -rf $(OUTPUT_DIR)
	@echo "Cleaning temporary files..."
	rm -f *.iso
	rm -rf work mount

clean-all: clean
	@echo "Removing Docker images..."
	docker rmi $(IMAGE_NAME) 2>/dev/null || true
	docker-compose down --rmi all 2>/dev/null || true

.DEFAULT_GOAL := help
