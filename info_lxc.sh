#!/bin/bash

echo "📦 Listado de contenedores LXC y sus redes"
echo "--------------------------------------------"

CONTAINERS=$(lxc-ls -1)

if [ -z "$CONTAINERS" ]; then
    echo "❌ No hay contenedores LXC creados."
    exit 0
fi

for container in $CONTAINERS; do
    echo ""
    echo "🔹 Contenedor: $container"

    # Estado del contenedor
    state=$(lxc-info -n "$container" | grep "State:" | awk '{print $2}')
    echo "   Estado: $state"

    # Si está corriendo, obtener red desde lxc-info
    if [ "$state" == "RUNNING" ]; then
        echo "   Interfaces activas:"
        lxc-info -n "$container" | grep -E 'Link:' | while read -r line; do
            iface=$(echo "$line" | awk '{print $2}')
            bridge=$(brctl show "$iface" 2>/dev/null | awk 'NR==2 {print $1}')
            echo "     - $iface (bridge: $bridge)"
        done
    else
        echo "   Interfaces configuradas:"
        grep -E '^lxc.net\.[0-9]+\.link' "/var/lib/lxc/$container/config" 2>/dev/null | while read -r line; do
            iface=$(echo "$line" | cut -d'=' -f2 | xargs)
            echo "     - $iface"
        done
    fi
done

echo ""
echo "✅ Listado completado."
