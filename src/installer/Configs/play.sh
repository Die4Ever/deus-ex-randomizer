#!/bin/bash

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd "$SCRIPT_DIR"
exec > >(tee playoutput.log) 2>&1

APP_REG_KEY="HKEY_CURRENT_USER\Software\Wine\AppDefaults\DeusEx.exe\Drivers"

echo "existing $APP_REG_KEY value:"
wine reg query "$APP_REG_KEY" /v Graphics

# check for Wayland
if [ -n "$WAYLAND_DISPLAY" ]; then
    echo "using Wayland"
    wine reg add "$APP_REG_KEY" /v Graphics /d 'wayland,x11' /f
else
    echo "using X11"
    wine reg add "$APP_REG_KEY" /v Graphics /d 'x11,wayland' /f
fi

wine reg add "HKEY_CURRENT_USER\Software\Wine\AppDefaults\DeusEx.exe\X11 Driver" /v UseTakeFocus /d "y" /f

echo "saved $APP_REG_KEY value:"
wine reg query "$APP_REG_KEY" /v Graphics

wine System/DeusEx.exe -localdata
