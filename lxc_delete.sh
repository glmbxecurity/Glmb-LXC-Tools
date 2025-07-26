#!/bin/bash

# Obtener lista de contenedores existentes (uno por línea)
readarray -t CONTAINERS < <(lxc-ls -1)

if [ ${#CONTAINERS[@]} -eq 0 ]; then
    echo "❌ No hay contenedores LXC existentes."
    exit 0
fi

echo ""
echo "📋 Contenedores disponibles:"
for i in "${!CONTAINERS[@]}"; do
    printf "%3d) %s\n" $((i+1)) "${CONTAINERS[$i]}"
done

echo ""
echo "Elige qué contenedores eliminar:"
echo " - Puedes escribir números separados por comas (ej: 1,3,5)"
echo " - O escribir 'todos' para eliminarlos todos"

read -p "Tu selección: " SEL

if [[ "$SEL" == "todos" ]]; then
    SELECCIONADOS=("${CONTAINERS[@]}")
else
    IFS=',' read -ra NUMS <<< "$SEL"
    SELECCIONADOS=()
    for num in "${NUMS[@]}"; do
        if ! [[ "$num" =~ ^[0-9]+$ ]] || [ "$num" -lt 1 ] || [ "$num" -gt ${#CONTAINERS[@]} ]; then
            echo "❌ Opción inválida: $num"
            exit 1
        fi
        SELECCIONADOS+=("${CONTAINERS[$((num-1))]}")
    done
fi

echo ""
echo "⚠️ Vas a eliminar los siguientes contenedores:"
for c in "${SELECCIONADOS[@]}"; do
    echo " - $c"
done

read -p "¿Estás seguro? (s/N): " CONFIRM
if [[ "$CONFIRM" != "s" && "$CONFIRM" != "S" ]]; then
    echo "❌ Operación cancelada."
    exit 0
fi

for c in "${SELECCIONADOS[@]}"; do
    echo ""
    echo "⏹️  Deteniendo contenedor $c (si está en ejecución)..."
    lxc-stop -n "$c" 2>/dev/null

    echo "🗑️  Eliminando contenedor $c..."
    lxc-destroy -n "$c"

    if [ $? -eq 0 ]; then
        echo "✅ Contenedor $c eliminado."
    else
        echo "❌ Falló la eliminación de $c"
    fi
done

echo ""
echo "🏁 Proceso finalizado."

