#!/bin/dash

# Color Configuration
BG="#1c1e20"
FG="#d8dee9"
GREEN="#7aa283"
GRAY="#5c6370"

# Nerd Font Icons
ICON_CLOCK=""
ICON_VOL=""
ICON_CPU=""
ICON_RAM=""  
ICON_DISK=""
ICON_LAN=""
ICON_TEMP=""   

# --- VOLATILE MODULES (Fast execution) ---

clock() {
    echo "%{F$GREEN}$ICON_CLOCK%{F-} $(date '+%a %d %b • %H:%M')"
}

cpu_temp() {
    if [ -f /sys/class/thermal/thermal_zone0/temp ]; then
        # Direct kernel sysfs read (Fastest method possible)
        read -r TEMP_RAW < /sys/class/thermal/thermal_zone0/temp
        echo "%{F$GRAY}│%{F-} %{F$GREEN}$ICON_TEMP%{F-} $((TEMP_RAW / 1000))°C"
    else
        echo "%{F$GRAY}│%{F-} %{F$GREEN}$ICON_TEMP%{F-} --°C"
    fi
}

volume() {
    RAW=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null)
    if [ -z "$RAW" ]; then
        echo "%{F$GRAY}│%{F-} %{F$GREEN}$ICON_VOL%{F-} --%"
        return
    fi

    if echo "$RAW" | grep -q "MUTED"; then
        VOL="MUTED"
    else
        # Converts float (0.50) to percentage (50%)
        VOL=$(echo "$RAW" | awk '{print int($2 * 100)"%"}')
    fi
    echo "%{F$GRAY}│%{F-} %{F$GREEN}$ICON_VOL%{F-} $VOL"
}

ram() {
    # Efficient parsing of /proc/meminfo directly without spawning 'free'
    # This reads the first 3 lines of meminfo and extracts Total and Available RAM
    RAM_DATA=$(awk '/MemTotal/ {t=$2} /MemAvailable/ {a=$2; print int((t-a)/t*100)"%"}' /proc/meminfo)
    echo "%{F$GRAY}│%{F-} %{F$GREEN}$ICON_RAM%{F-} $RAM_DATA"
}

cpu() {
    # Replaced 'vmstat 1 2' with an instantaneous system load average calculation
    # Reads /proc/loadavg (Instantaneous, zero delay)
    read -r LOAD_1 _ < /proc/loadavg
    echo "%{F$GREEN}$ICON_CPU%{F-} $LOAD_1"
}

workspaces() {
    echo " %{B$GREEN}%{F$BG}  1  %{B-}%{F-} %{F$GREEN} 2   3   4 %{F-}"
}

# --- CACHED MODULES (Updated conditionally to save CPU cycles) ---

network() {
    if ip route | grep -q default; then
        CURRENT_NET="%{F$GRAY}│%{F-} %{F$GREEN}$ICON_LAN%{F-} Enthernet"
    else
        CURRENT_NET="%{F$GRAY}│%{F-} %{F$GRAY}󰈀 Desc.%{F-}"
    fi
}

disk() {
    CURRENT_DISK="%{F$GRAY}│%{F-} %{F$GREEN}$ICON_DISK%{F-} $(df -h / | awk 'NR==2 {print $5}')"
}

# --- INITIALIZATION & MAIN LOOP ---

# Initialize cached values on startup
network
disk
SEC_COUNT=0

while true; do
    # Every 30 seconds, update network status and disk space
    if [ "$SEC_COUNT" -eq 30 ]; then
        network
        disk
        SEC_COUNT=0
    fi

    # Output to Lemonbar
    echo "%{l}$(workspaces) $CURRENT_NET $(cpu_temp)%{c}$(clock)%{r}$(cpu) $(ram) $CURRENT_DISK $(volume) "
    
    sleep 1
    SEC_COUNT=$((SEC_COUNT + 1))
done
