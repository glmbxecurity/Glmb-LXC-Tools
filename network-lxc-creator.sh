#!/bin/bash
clear
echo "🔧 LXC Network Creator"
echo ""
#!/bin/bash

echo "¿Cuántas interfaces lxcbr quieres crear?"
read NUM_BRIDGES

# Validar que sea un número positivo
if ! [[ "$NUM_BRIDGES" =~ ^[1-9][0-9]*$ ]]; then
    echo "Número inválido. Saliendo..."
    exit 1
fi

for ((i=1; i<=NUM_BRIDGES; i++)); do
    echo "Nombre de la interfaz #$i (ej. lxcbr1):"
    read BRIDGE_NAME

    # Verificar que no exista
    if ip link show "$BRIDGE_NAME" &>/dev/null; then
        echo "⚠ $BRIDGE_NAME ya existe, saltando..."
        continue
    fi

    echo "Dirección IP para $BRIDGE_NAME (ej. 10.0.$i.1/24):"
    read BRIDGE_IP

    echo "Creando $BRIDGE_NAME con IP $BRIDGE_IP..."
    ip link add name "$BRIDGE_NAME" type bridge
    ip addr add "$BRIDGE_IP" dev "$BRIDGE_NAME"
    ip link set dev "$BRIDGE_NAME" up

    echo "✅ $BRIDGE_NAME creado."
done

echo "✅ Todas las interfaces creadas."
echo ""
echo "🎉 Todos los contenedores han sido creados."
