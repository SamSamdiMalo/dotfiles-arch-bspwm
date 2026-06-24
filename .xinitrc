#!/bin/sh

# 1 cargar recursos de X (fuentes, colores básicos)
if [ -f /etc/X11/xinit/.Xresources ]; then
	xrdb -merge /etc/X11/xinit/.Xresources
fi

xsetroot -cursor_name left_ptr &

setxkbmap latam &

pgrep -x sxhkd > /dev/null || sxhkd &

# 2 programas que corren en segundo plano
export XDG_RUNTIME_DIR=/run/user/$(id -u) &
sxhkd &
picom &
dunst &
hsetroot -solid "#282828" &

# 3 wm
exec bspwm
