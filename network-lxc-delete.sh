#!/bin/bash

# Elimina todas las interfaces lxcbrX excepto lxcbr0

echo "Buscando interfaces lxcbrX (excepto lxcbr0)..."

# Buscar interfaces que coincidan con lxcbr y no sean lxcbr0
for bridge in $(ip -o link show | awk -F': ' '{print $2}' | grep -E '^lxcbr[1-9][0-9]*$'); do
    echo "Eliminando $bridge..."
    ip link set dev "$bridge" down 2>/dev/null
    ip link delete "$bridge" type bridge 2>/dev/null
done

echo "✅ Interfaces eliminadas (excepto lxcbr0)."
