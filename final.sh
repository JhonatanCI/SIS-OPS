\#!/bin/bash

# 1. Desplegar los cinco procesos que más CPU estén consumiendo en ese momento.
echo "Selecciona una de las siguientes opciones: "
echo "1) Mostrar los procesos que mas CPU consumen"
echo "2) Desplegar  los  filesystems  o  discos  conectados  a  la  máquina."
echo "3)  Desplegar  el  nombre  y  el  tamaño  del  archivo  más  grande  almacenado  en  un  disco  o filesystem"
echo "4) Cantidad de memoria libre y cantidad del espacio de swap en uso "
echo "5) Número de conexiones de red activas actualmente"
read option
if [$option -eq 1] then

 echo "Los cinco procesos que más CPU están consumiendo:"
 ps -eo pid,comm,%cpu --sort=-%cpu | head -n 6
 echo

fi

if [$option -eq 2] then
# 2. Desplegar los filesystems o discos conectados a la máquina. Incluir para cada disco su tamaño y la cantidad de espacio libre (en bytes).
echo "Filesystems y discos conectados con su tamaño y espacio libre:"
df -B1 --output=source,size,avail | grep '^/dev/'
echo
fi

if [$option -eq 3] then
# 3. Desplegar el nombre y el tamaño del archivo más grande almacenado en un disco o filesystem especificado por el usuario.
read -p "Ingrese el filesystem o directorio para buscar el archivo más grande: " filesystem
if [ -d "$filesystem" ]; then
    echo "El archivo más grande en $filesystem es:"
    find "$filesystem" -type f -exec ls -s {} + | sort -n -r | head -n 1
else
    echo "El filesystem o directorio especificado no existe."
fi
echo
fi
# 4. Cantidad de memoria libre y cantidad del espacio de swap en uso (en bytes y porcentaje).
echo "Memoria libre y espacio de swap en uso:"
free -b | awk '
/Mem:/ { 
    mem_free=$4; 
    mem_total=$2 
}
/Swap:/ { 
    swap_used=$3; 
    swap_total=$2 
    swap_percent = (swap_used/swap_total) * 100 
}
END { 
    printf "Memoria libre: %d bytes\n", mem_free
    printf "Swap en uso: %d bytes (%.2f%%)\n", swap_used, swap_percent 
}'
echo

# 5. Número de conexiones de red activas actualmente (en estado ESTABLISHED).
echo "Número de conexiones de red activas (ESTABLISHED):"
netstat -an | grep 'ESTABLISHED' | wc -l

