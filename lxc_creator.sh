#!/bin/bash

# Obtener y guardar combinaciones válidas de distro y release para amd64
echo "⏳ Obteniendo lista de distribuciones disponibles (amd64)..."

readarray -t OPTIONS < <(lxc-create -n dummy -t download -- --list 2>/dev/null | awk '$3=="amd64" {print $1" "$2}' | sort -u)

if [ ${#OPTIONS[@]} -eq 0 ]; then
    echo "❌ No se pudo obtener la lista de plantillas disponibles. Verifica tu conexión o instalación de LXC."
    exit 1
fi

# Mostrar las opciones al usuario
echo ""
echo "📋 Distribuciones disponibles (amd64):"
for i in "${!OPTIONS[@]}"; do
    printf "%3d) %s\n" $((i+1)) "${OPTIONS[$i]}"
done

# Solicitar selección
echo ""
read -p "Elige una opción por número (1-${#OPTIONS[@]}): " SEL

if ! [[ "$SEL" =~ ^[1-9][0-9]*$ ]] || [ "$SEL" -lt 1 ] || [ "$SEL" -gt ${#OPTIONS[@]} ]; then
    echo "❌ Selección inválida."
    exit 1
fi

# Obtener distro y release de la selección
DISTRO=$(echo "${OPTIONS[$((SEL-1))]}" | awk '{print $1}')
RELEASE=$(echo "${OPTIONS[$((SEL-1))]}" | awk '{print $2}')
ARCH="amd64"

echo ""
echo "✅ Elegiste: $DISTRO $RELEASE ($ARCH)"

# Pedir cantidad de contenedores
read -p "¿Cuántos contenedores deseas crear? " CANT

if ! [[ "$CANT" =~ ^[1-9][0-9]*$ ]]; then
    echo "❌ Número inválido."
    exit 1
fi

# Crear cada contenedor
for (( i=1; i<=CANT; i++ )); do
    echo ""
    read -p "Nombre para el contenedor #$i (ej: cont$i): " NAME
    if [[ -z "$NAME" ]]; then
        echo "❌ Nombre no válido. Saltando contenedor $i."
        continue
    fi

    read -p "Interfaces puente para $NAME (separadas por comas, ej: lxcbr1,lxcbr2): " INTERFACES
    if [[ -z "$INTERFACES" ]]; then
        echo "❌ No se especificaron interfaces. Saltando contenedor $NAME."
        continue
    fi

    echo "🛠️  Creando contenedor $NAME con $DISTRO $RELEASE ($ARCH)..."
    lxc-create -n "$NAME" -t download -- --dist "$DISTRO" --release "$RELEASE" --arch "$ARCH"
    if [ $? -ne 0 ]; then
        echo "❌ Error creando contenedor $NAME"
        continue
    fi

    CONFIG="/var/lib/lxc/$NAME/config"
    sed -i '/^lxc.net/d' "$CONFIG"

    IFS=',' read -ra BRIDGES <<< "$INTERFACES"
    for idx in "${!BRIDGES[@]}"; do
        iface=$(echo "${BRIDGES[$idx]}" | xargs)
        echo "" >> "$CONFIG"
        echo "lxc.net.$idx.type = veth" >> "$CONFIG"
        echo "lxc.net.$idx.link = $iface" >> "$CONFIG"
        echo "lxc.net.$idx.flags = up" >> "$CONFIG"
    done

    echo "✅ Contenedor $NAME creado y configurado."
done

echo ""
echo "🎉 Todos los contenedores han sido procesados."
