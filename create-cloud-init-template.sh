#!/bin/bash
#
# PRXDash Cloud-Init Template Creator
# ===================================
# Creates a standardized cloud-init VM template on Proxmox VE
# 
# Usage: ./create-cloud-init-template.sh [OPTIONS]
#
# Options:
#   -i, --vmid        Template VMID (default: 9000)
#   -n, --name        Template name (default: cloud-init-template)
#   -s, --storage     Storage pool (default: local-lvm)
#   -b, --bridge      Network bridge (default: vmbr0)
#   -d, --distro      Distribution: ubuntu24, ubuntu22, debian12 (default: ubuntu24)
#   -h, --help        Show this help
#

set -e

# ============================================
# Default Configuration
# ============================================
VMID="${VMID:-9000}"
TEMPLATE_NAME="${TEMPLATE_NAME:-cloud-init-template}"
STORAGE="${STORAGE:-local-lvm}"
BRIDGE="${BRIDGE:-vmbr0}"
DISTRO="${DISTRO:-ubuntu24}"

MEMORY=2048
CORES=2
DISK_SIZE="32G"

# Cloud Image URLs
declare -A CLOUD_IMAGES=(
    ["ubuntu24"]="https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
    ["ubuntu22"]="https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
    ["debian12"]="https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-generic-amd64.qcow2"
)

declare -A DISTRO_NAMES=(
    ["ubuntu24"]="Ubuntu 24.04 LTS"
    ["ubuntu22"]="Ubuntu 22.04 LTS"
    ["debian12"]="Debian 12 Bookworm"
)

# ============================================
# Functions
# ============================================

print_header() {
    echo ""
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║        PRXDash Cloud-Init Template Creator                   ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""
}

print_step() {
    echo "→ $1"
}

print_success() {
    echo "✓ $1"
}

print_error() {
    echo "✗ ERROR: $1" >&2
    exit 1
}

show_help() {
    head -20 "$0" | tail -15
    exit 0
}

check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_error "This script must be run as root on a Proxmox node"
    fi
}

check_vmid_available() {
    if qm status "$VMID" &>/dev/null; then
        print_error "VMID $VMID already exists. Use -i to specify a different ID."
    fi
}

# ============================================
# Parse Arguments
# ============================================

while [[ $# -gt 0 ]]; do
    case $1 in
        -i|--vmid)
            VMID="$2"
            shift 2
            ;;
        -n|--name)
            TEMPLATE_NAME="$2"
            shift 2
            ;;
        -s|--storage)
            STORAGE="$2"
            shift 2
            ;;
        -b|--bridge)
            BRIDGE="$2"
            shift 2
            ;;
        -d|--distro)
            DISTRO="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            ;;
        *)
            print_error "Unknown option: $1"
            ;;
    esac
done

# Validate distro
if [[ -z "${CLOUD_IMAGES[$DISTRO]}" ]]; then
    print_error "Unknown distribution: $DISTRO. Use: ubuntu24, ubuntu22, debian12"
fi

CLOUD_IMAGE_URL="${CLOUD_IMAGES[$DISTRO]}"
DISTRO_NAME="${DISTRO_NAMES[$DISTRO]}"

# ============================================
# Main Script
# ============================================

print_header
check_root
check_vmid_available

echo "Configuration:"
echo "  VMID:         $VMID"
echo "  Name:         $TEMPLATE_NAME"
echo "  Distribution: $DISTRO_NAME"
echo "  Storage:      $STORAGE"
echo "  Bridge:       $BRIDGE"
echo "  Memory:       ${MEMORY}MB"
echo "  CPUs:         $CORES"
echo "  Disk:         $DISK_SIZE"
echo ""

# Determine image filename
IMAGE_FILE="/tmp/cloud-init-${DISTRO}.img"

# Step 1: Download cloud image
print_step "Downloading $DISTRO_NAME cloud image..."
if [[ -f "$IMAGE_FILE" ]]; then
    echo "  Using cached image: $IMAGE_FILE"
else
    wget -q --show-progress -O "$IMAGE_FILE" "$CLOUD_IMAGE_URL"
fi
print_success "Cloud image ready"

# Step 2: Install qemu-guest-agent into the image
print_step "Installing qemu-guest-agent into image..."
if command -v virt-customize &>/dev/null; then
    virt-customize -a "$IMAGE_FILE" \
        --install qemu-guest-agent \
        --run-command 'systemctl enable qemu-guest-agent' \
        2>/dev/null || echo "  Warning: virt-customize failed, skipping package install"
else
    echo "  Note: libguestfs-tools not installed, skipping package pre-install"
    echo "  Install with: apt install libguestfs-tools"
fi
print_success "Image customization complete"

# Step 3: Create the VM
print_step "Creating VM $VMID..."
qm create "$VMID" \
    --name "$TEMPLATE_NAME" \
    --ostype l26 \
    --machine q35 \
    --bios ovmf \
    --cpu host \
    --cores "$CORES" \
    --memory "$MEMORY" \
    --balloon "$MEMORY" \
    --net0 "virtio,bridge=$BRIDGE,firewall=1" \
    --scsihw virtio-scsi-single \
    --agent enabled=1 \
    --tags "cloud-init,template"

print_success "VM created"

# Step 4: Import disk
print_step "Importing disk to $STORAGE..."
qm importdisk "$VMID" "$IMAGE_FILE" "$STORAGE" --format qcow2
print_success "Disk imported"

# Step 5: Attach disk and configure boot
print_step "Configuring disk and boot order..."
qm set "$VMID" \
    --scsi0 "$STORAGE:vm-$VMID-disk-0,discard=on,ssd=1" \
    --boot order=scsi0 \
    --efidisk0 "$STORAGE:1,format=qcow2,efitype=4m,pre-enrolled-keys=1"

# Resize disk to target size
qm disk resize "$VMID" scsi0 "$DISK_SIZE"
print_success "Disk configured and resized to $DISK_SIZE"

# Step 6: Add Cloud-Init drive
print_step "Adding Cloud-Init drive..."
qm set "$VMID" --ide2 "$STORAGE:cloudinit"
print_success "Cloud-Init drive added"

# Step 7: Configure Cloud-Init defaults
print_step "Setting Cloud-Init defaults..."
qm set "$VMID" \
    --citype nocloud \
    --ipconfig0 "ip=dhcp"
print_success "Cloud-Init configured (DHCP default, supports static IP)"

# Step 8: Enable QEMU Guest Agent
print_step "Enabling QEMU Guest Agent..."
qm set "$VMID" --agent enabled=1
print_success "QEMU Guest Agent enabled"

# Step 9: Protect template
print_step "Enabling template protection..."
qm set "$VMID" --protection 1
print_success "Template protected from accidental deletion"

# Step 10: Convert to template
print_step "Converting VM to template..."
qm template "$VMID"
print_success "VM converted to template"

# ============================================
# Summary
# ============================================

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                    Template Created!                         ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
echo "Template Details:"
echo "  VMID:     $VMID"
echo "  Name:     $TEMPLATE_NAME"
echo "  Distro:   $DISTRO_NAME"
echo "  Storage:  $STORAGE"
echo ""
echo "Usage in PRXDash:"
echo "  - Select this template when creating new VMs"
echo "  - Configure Cloud-Init: user, SSH keys, network"
echo ""
echo "Manual Clone Example:"
echo "  qm clone $VMID NEW_VMID --name my-new-vm --full"
echo ""
echo "Static IP Configuration:"
echo "  qm set NEW_VMID --ipconfig0 'ip=192.168.1.100/24,gw=192.168.1.1'"
echo ""
