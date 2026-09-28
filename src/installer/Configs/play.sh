#!/bin/bash
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd "$SCRIPT_DIR"

APP_REG_KEY="HKEY_CURRENT_USER\Software\Wine\AppDefaults\DeusEx.exe\Drivers"

# check for Wayland
if [ -n "$WAYLAND_DISPLAY" ]; then
    echo "using Wayland"
    unset DISPLAY
    wine reg add "$APP_REG_KEY" /v Graphics /d 'wayland' /f
else
    echo "using X11"
    wine reg add "$APP_REG_KEY" /v Graphics /d 'x11' /f
fi

# try to find wineserver
WINESERVER_CMD=$(which wineserver 2>/dev/null || which "${WINE:-wine}server" 2>/dev/null || echo "$(dirname "$(which wine)")/wineserver")

if [ -x "$WINESERVER_CMD" ]; then
    # wait for registry updates
    "$WINESERVER_CMD" -w
else
    # else just sleep to make sure registry writing is completed
    echo "fallback sleeping"
    sleep 0.3
fi

wine System/DeusEx.exe -localdata
