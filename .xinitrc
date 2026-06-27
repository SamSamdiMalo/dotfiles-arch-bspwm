#!/bin/sh

# =============================================================================
# 1. ENVIRONMENT & SYSTEM RESOURCES SETUP
# =============================================================================

# FIX: Export runtime directory synchronously. Do NOT background (&) this command, 
# otherwise child processes (bspwm, terminal, etc.) won't inherit the variable.
export XDG_RUNTIME_DIR="/run/user/$(id -u)"

# Merge system-wide X11 resources if available
if [ -f /etc/X11/xinit/.Xresources ]; then
    xrdb -merge /etc/X11/xinit/.Xresources
fi

# OPTIMIZATION: Merge local user configurations (Crucial for custom font rendering)
if [ -f "$HOME/.Xresources" ]; then
    xrdb -merge "$HOME/.Xresources"
fi

# Set default X11 mouse cursor theme
xsetroot -cursor_name left_ptr &

# Set keyboard layout to Latin American
setxkbmap latam &

# Set a flat solid color for the root window background
# Note: Color changed to match your Lemonbar theme (#1c1e20) for visual consistency!
hsetroot -solid "#1c1e20" &

# =============================================================================
# 2. BACKGROUND DAEMONS & UTILITIES
# =============================================================================

# Notification Daemon
dunst &

# FIX: Hotkey daemon guard. Only launch sxhkd if it isn't already running.
# This prevents duplicate process trees and keybinding collisions.
pgrep -x sxhkd > /dev/null || sxhkd &

# X11 Compositor (Handles transparency and eliminates screen tearing)
# PERFORMANCE NOTE: On 2007 hardware, if you experience graphical lag,
# launch this using the legacy backend: picom --backend xrender &
pgrep -x picom > /dev/null || picom &

# =============================================================================
# 3. WINDOW MANAGER EXECUTION
# =============================================================================

# Replace the current shell process with bspwm
exec bspwm
