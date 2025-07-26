#!/bin/bash

read -p "¿Cuántos puentes deseas crear? " CANTIDAD

# Validar que el número sea entre 1 y 254 (para IPs válidas en 172.16.X.1/24)
if ! [[ "$CANTIDAD" =~ ^[1-9][0-9]*$ ]] || [ "$CANTIDAD" -gt 254 ]; then
    echo "Por favor, ingresa un número válido entre 1 y 254."
    exit 1
fi

for (( i=1; i<=CANTIDAD; i++ )); do
    BRIDGE="lxcbr$i"
    IP="172.16.$i.1/24"

    echo "Creando $BRIDGE con IP $IP..."

    # Verificar si el puente ya existe
    if ip link show "$BRIDGE" &>/dev/null; then
        echo "⚠️  El puente $BRIDGE ya existe. Saltando..."
        continue
    fi

    # Crear y configurar el puente
    ip link add name $BRIDGE type bridge
    ip addr add $IP dev $BRIDGE
    ip link set dev $BRIDGE up
done

echo "✅ Puentes creados correctamente."

