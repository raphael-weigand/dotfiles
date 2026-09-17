#!/usr/bin/env bash

if pgrep -f 'localsend_app' >/dev/null 2>&1; then
    pkill -f 'localsend_app'
else
    nohup localsend_app >/dev/null 2>&1 &
fi
