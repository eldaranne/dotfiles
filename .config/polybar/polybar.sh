#!/usr/bin/env sh
killall -q polybar
while pgrep -x polybar >/dev/null; do sleep 1; done
polybar top-left & 
#polybar bottom-left &
polybar top-right &
#polybar bottom-right &

