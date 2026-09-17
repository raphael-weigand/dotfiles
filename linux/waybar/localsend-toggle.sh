#!/usr/bin/env bash

if pgrep -x localsend >/dev/null 2>&1; then
    pkill -x localsend
else
    nohup localsend >/dev/null 2>&1 &
fi
