#!/usr/bin/env bash

if pgrep -f 'localsend_app' >/dev/null 2>&1; then
    printf '{"text":"󰒍","tooltip":"LocalSend: aktiv","class":"active"}\n'
else
    printf '{"text":"󰒍","tooltip":"LocalSend: aus","class":"inactive"}\n'
fi
