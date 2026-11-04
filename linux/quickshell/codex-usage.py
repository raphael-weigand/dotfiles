#!/usr/bin/env python3
"""Adapt mryll/codexbar structured JSON (schema v2) for Quickshell."""
import json
import subprocess
import sys

def find_window(windows, seconds, names):
    for window in windows:
        if not isinstance(window, dict):
            continue
        if window.get("window_seconds") == seconds and not window.get("group"):
            return window
    for window in windows:
        if not isinstance(window, dict) or window.get("group"):
            continue
        label = str(window.get("id", "")) + " " + str(window.get("label", ""))
        if any(name in label.lower() for name in names):
            return window
    return None

def reset_time(window):
    if not window:
        return None
    for key in ("resets_at", "reset_at", "resetAt", "resetsAt", "reset_time", "resetTime"):
        value = window.get(key)
        if isinstance(value, (int, float)) and not isinstance(value, bool):
            return value
        if isinstance(value, str) and value.strip():
            return value
    return None

def percentage(window):
    if not window:
        return None
    value = window.get("used_pct")
    if isinstance(value, (int, float)) and not isinstance(value, bool):
        return max(0, min(100, float(value)))
    return None

try:
    result = subprocess.run(
        ["codexbar", "--json"] + (["--refresh"] if "--refresh" in sys.argv[1:] else []), capture_output=True, text=True,
        timeout=20, check=True
    )
    data = json.loads(result.stdout)
    if not isinstance(data, dict):
        raise ValueError("Unexpected CodexBar response")
    error = data.get("error")
    if error:
        message = error.get("message", str(error)) if isinstance(error, dict) else str(error)
        raise ValueError(message)
    windows = data.get("windows") or []
    if isinstance(windows, dict):
        windows = list(windows.values())
    if not isinstance(windows, list):
        raise ValueError("Invalid CodexBar windows")
    session_window = find_window(windows, 18000, ("session", "5h", "5-hour", "5 hour"))
    week_window = find_window(windows, 604800, ("weekly", "week", "7d"))
    session = percentage(session_window)
    week = percentage(week_window)
    message = ""
    if session is None and week is None:
        message = "Loading Codex usage…" if data.get("loading") else "No usage windows available"
    print(json.dumps({"session": session, "week": week, "sessionReset": reset_time(session_window), "weekReset": reset_time(week_window), "error": message}))
except Exception as exc:
    print(json.dumps({"session": None, "week": None, "error": str(exc)}))
