#!/bin/dash

# Configuración de colores
BG="#1c1e20"
FG="#d8dee9"
GREEN="#7aa283"
GRAY="#5c6370"

# Iconos (Asegúrate de lanzar lemonbar con una Nerd Font)
ICON_CLOCK=""
ICON_VOL=""
ICON_CPU=""
ICON_RAM=""  
ICON_DISK=""
ICON_LAN=""
ICON_TEMP=""   

# Módulo de Red (Optimizado exclusivamente para Cable/Ethernet)
network() {
    # Comprueba si la interfaz por defecto está activa
    if ip route | grep -q default; then
        echo "%{F$GRAY}│%{F-} %{F$GREEN}$ICON_LAN%{F-} Cable"
    else
        echo "%{F$GRAY}│%{F-} %{F$GRAY}󰈀 Desc.%{F-}"
    fi
}

# Módulo de Temperatura de CPU
cpu_temp() {
    # Intenta leer directamente de la zona térmica del sistema (rápido y sin herramientas extra)
    if [ -f /sys/class/thermal/thermal_zone0/temp ]; then
        TEMP_RAW=$(cat /sys/class/thermal/thermal_zone0/temp)
        TEMP=$(echo "$TEMP_RAW" | awk '{print int($1 / 1000)"°C"}')
    else
        TEMP="--°C"
    fi
    echo "%{F$GRAY}│%{F-} %{F$GREEN}$ICON_TEMP%{F-} $TEMP"
}

# Módulo de Reloj
clock() {
    DATETIME=$(date "+%a %d %b • %H:%M")
    echo "%{F$GREEN}$ICON_CLOCK%{F-} $DATETIME"
}

# Módulo de Volumen (Nativo para PipeWire / WirePlumber)
volume() {
    RAW=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null)
    
    if [ -z "$RAW" ]; then
        echo "%{F$GRAY}│%{F-} %{F$GREEN}$ICON_VOL%{F-} --%"
        return
    fi

    if echo "$RAW" | grep -q "MUTED"; then
        VOL="MUTED"
    else
        VOL=$(echo "$RAW" | awk '{print int($2 * 100)"%"}')
    fi

    echo "%{F$GRAY}│%{F-} %{F$GREEN}$ICON_VOL%{F-} $VOL"
}

# Módulo de Memoria RAM
ram() {
    RAM_USAGE=$(free | grep Mem | awk '{print int($3/$2 * 100)"%"}')
    echo "%{F$GRAY}│%{F-} %{F$GREEN}$ICON_RAM%{F-} $RAM_USAGE"
}

# Módulo de Disco Duro
disk() {
    DISK_USAGE=$(df -h / | awk 'NR==2 {print $5}')
    echo "%{F$GRAY}│%{F-} %{F$GREEN}$ICON_DISK%{F-} $DISK_USAGE"
}

# Módulo de CPU (Corregido para promediar todos los núcleos como btop)
cpu() {
    # Lee el porcentaje de tiempo ocioso (idle) global y lo resta de 100
    CPU_USAGE=$(vmstat 1 2 | tail -n1 | awk '{print 100 - $15"%"}')
    echo "%{F$GREEN}$ICON_CPU%{F-} $CPU_USAGE"
}

# Módulo estético para Workspaces
workspaces() {
    echo " %{B$GREEN}%{F$BG}  1  %{B-}%{F-} %{F$GREEN} 2   3   4 %{F-}"
}

# Bucle principal que alimenta la barra
while true; do
    # %{l} Izquierda (Workspaces + Red + Temperatura)
    # %{c} Centro    (Reloj)
    # %{r} Derecha   (Hardware + Audio)
    echo "%{l}$(workspaces) $(network) $(cpu_temp)%{c}$(clock)%{r}$(cpu) $(ram) $(disk) $(volume) "
    sleep 1
done
