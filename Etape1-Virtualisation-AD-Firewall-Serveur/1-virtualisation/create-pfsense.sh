#!/bin/bash
# ============================================================
# Script de création VM PFsense pour VirtualBox
# Usage : ./create-pfsense.sh
# ============================================================

VM_NAME="PFsense"
OS_TYPE="FreeBSD_64"
RAM=1024
DISK_SIZE=10000
ISO_PATH="$HOME/isooperatingsystem/pfSense-Firewall.iso"
VDI_PATH="$HOME/VirtualBox VMs/$VM_NAME/$VM_NAME.vdi"

# ── Vérifications ──────────────────────────────────────────
if [ ! -f "$ISO_PATH" ]; then
    echo "❌ ISO introuvable : $ISO_PATH"
    exit 1
fi

if VBoxManage showvminfo "$VM_NAME" &>/dev/null; then
    echo "⚠️  La VM '$VM_NAME' existe déjà."
    exit 0
fi

# ── Vérification interface host-only ───────────────────────
if ! VBoxManage list hostonlyifs | grep -q "vboxnet0"; then
    echo "🔧 Création de l'interface host-only vboxnet0..."
    VBoxManage hostonlyif create
    VBoxManage hostonlyif ipconfig vboxnet0 \
        --ip 192.168.56.1 \
        --netmask 255.255.255.0
fi

echo "🔧 Création de la VM : $VM_NAME"

# ── 1. Créer et enregistrer la VM ──────────────────────────
VBoxManage createvm \
    --name "$VM_NAME" \
    --ostype "$OS_TYPE" \
    --register

# ── 2. Paramètres système ──────────────────────────────────
VBoxManage modifyvm "$VM_NAME" \
    --memory "$RAM" \
    --cpus 1 \
    --chipset piix3 \
    --ioapic on \
    --rtcuseutc on \
    --boot1 dvd \
    --boot2 disk \
    --boot3 none \
    --boot4 none \
    --vram 16 \
    --graphicscontroller vmsvga \
    --nic1 nat \
    --nic2 hostonly \
    --hostonlyadapter2 "vboxnet0"

# ── 3. Créer le disque VDI ─────────────────────────────────
mkdir -p "$(dirname "$VDI_PATH")"
VBoxManage createmedium disk \
    --filename "$VDI_PATH" \
    --size "$DISK_SIZE" \
    --format VDI \
    --variant Standard

# ── 4. Contrôleur SATA + disque dur ───────────────────────
VBoxManage storagectl "$VM_NAME" \
    --name "SATA Controller" \
    --add sata \
    --controller IntelAhci

VBoxManage storageattach "$VM_NAME" \
    --storagectl "SATA Controller" \
    --port 0 --device 0 \
    --type hdd \
    --medium "$VDI_PATH"

# ── 5. Contrôleur IDE + ISO ────────────────────────────────
VBoxManage storagectl "$VM_NAME" \
    --name "IDE Controller" \
    --add ide \
    --controller PIIX3

VBoxManage storageattach "$VM_NAME" \
    --storagectl "IDE Controller" \
    --port 0 --device 0 \
    --type dvddrive \
    --medium "$ISO_PATH"

echo ""
echo "✅ VM '$VM_NAME' créée avec succès."
echo ""
echo "   Carte réseau :"
echo "   NIC1 (WAN) → NAT       (accès internet)"
echo "   NIC2 (LAN) → vboxnet0  (réseau interne 192.168.56.0/24)"
echo ""
echo "   💡 Après installation PFsense :"
echo "      WAN → obtient une IP via NAT VirtualBox"
echo "      LAN → à configurer en 192.168.56.1/24"
echo ""
echo "   ▶️  Lancez la VM avec :"
echo "      VBoxManage startvm '$VM_NAME' --type gui"
