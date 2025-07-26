#!/bin/bash

echo "🔧 LXC Container Creator"

read -p "¿Cuántos contenedores deseas crear?: " COUNT

# Obtener lista de templates disponibles
TEMPLATE_LIST=$(lxc-create -n dummy -t download -- --list | awk '$3=="amd64" {print $1" "$2}' | sort -u)
TEMPLATES=($(echo "$TEMPLATE_LIST" | awk '{print $1" "$2}'))
echo ""
echo "📦 Plantillas disponibles:"
i=1
while IFS= read -r line; do
    echo "  [$i] $line"
    TEMPLATE_OPTIONS[$i]="$line"
    ((i++))
done <<< "$TEMPLATE_LIST"

read -p "Selecciona una plantilla (número): " TEMPLATE_INDEX
SELECTED="${TEMPLATE_OPTIONS[$TEMPLATE_INDEX]}"
DISTRO=$(echo "$SELECTED" | awk '{print $1}')
RELEASE=$(echo "$SELECTED" | awk '{print $2}')
ARCH="amd64"

# Preguntar si se quieren asignar IPs
read -p "¿Quieres asignar IPs manualmente a las interfaces? [s/n]: " ASSIGN_IP

for ((j = 1; j <= COUNT; j++)); do
    echo ""
    read -p "Nombre para el contenedor #$j: " NAME
    read -p "Interfaces a conectar (separadas por comas, ej: lxcbr1,lxcbr2): " IFACES_RAW
    IFS=',' read -ra IFACES <<< "$IFACES_RAW"

    echo "⏳ Creando contenedor $NAME con $DISTRO $RELEASE ($ARCH)..."
    lxc-create -n "$NAME" -t download -- --dist "$DISTRO" --release "$RELEASE" --arch "$ARCH"

    CONFIG="/var/lib/lxc/$NAME/config"

    # Limpiar configuración de red anterior
    sed -i '/^lxc.net\./d' "$CONFIG"

    i=0
    for BR in "${IFACES[@]}"; do
        echo "Configurando interfaz ${BR}..."

        echo "lxc.net.$i.type = veth" >> "$CONFIG"
        echo "lxc.net.$i.link = $BR" >> "$CONFIG"
        echo "lxc.net.$i.flags = up" >> "$CONFIG"

        if [[ "$ASSIGN_IP" =~ ^[sS]$ ]]; then
            read -p " → IP para la interfaz $BR (formato CIDR, ej: 172.16.1.100/24): " IP
            echo "lxc.net.$i.ipv4.address = $IP" >> "$CONFIG"
            echo "lxc.net.$i.ipv4.gateway = auto" >> "$CONFIG"
        fi
        ((i++))
    done

    echo "✅ Contenedor $NAME creado."
done

echo ""
echo "🎉 Todos los contenedores han sido creados."
