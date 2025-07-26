#!/bin/bash

echo "📦 Listado de contenedores LXC, su estado, interfaces y direcciones IP"
echo "-----------------------------------------------------------------------"

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

    CONFIG="/var/lib/lxc/$container/config"

    if [ "$state" == "RUNNING" ]; then
        echo "   Interfaces activas:"
        lxc-info -n "$container" | grep -E 'Link:' | while read -r line; do
            iface=$(echo "$line" | awk '{print $2}')
            bridge=$(brctl show "$iface" 2>/dev/null | awk 'NR==2 {print $1}')

            # Obtener IP interna dentro del contenedor (requiere estar activo)
            ip=$(lxc-attach -n "$container" -- ip -4 addr show dev "$iface" 2>/dev/null | grep -oP 'inet \K[\d./]+')

            echo "     - $iface (bridge: $bridge, IP: ${ip:-N/A})"
        done
    else
        echo "   Interfaces configuradas:"
        grep -E '^lxc.net\.[0-9]+\.(link|ipv4\.address)' "$CONFIG" 2>/dev/null | \
        awk -F= '{gsub(/^[ \t]+|[ \t]+$/, "", $2); print $1 "=" $2}' | \
        awk '
            {
                split($1, parts, ".");
                idx = parts[3];
                if ($1 ~ /\.link$/) iface[idx] = $2;
                if ($1 ~ /\.ipv4\.address$/) ip[idx] = $2;
            }
            END {
                for (i in iface) {
                    printf "     - %s (IP: %s)\n", iface[i], (ip[i] ? ip[i] : "N/A");
                }
            }'
    fi
done

echo ""
echo "✅ Listado completado."
