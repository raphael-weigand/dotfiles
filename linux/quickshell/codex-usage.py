#!/usr/bin/env python3
"""Normalize CodexBar JSON into a stable, minimal Quickshell payload."""
import json
import subprocess
import sys

def pick_percent(obj, *keys):
    if not isinstance(obj, dict):
        return None
    for key in keys:
        value = obj.get(key)
        if isinstance(value, dict):
            result = pick_percent(value, "used_percent", "usedPercent", "percent_used", "percentUsed", "percentage", "percent")
            if result is not None:
                return result
        elif isinstance(value, (int, float)) and not isinstance(value, bool):
            return max(0, min(100, float(value)))
    return None

try:
    result = subprocess.run(["codexbar", "--json"], capture_output=True, text=True, timeout=15, check=True)
    data = json.loads(result.stdout)
    if isinstance(data, list):
        data = next((entry for entry in data if isinstance(entry, dict) and
                     "codex" in str(entry.get("provider", entry.get("name", ""))).lower()), data[0] if data else {})
    if isinstance(data, dict) and isinstance(data.get("codex"), dict):
        data = data["codex"]
    session = pick_percent(data, "session", "five_hour", "fiveHour", "primary", "sessionPercent")
    week = pick_percent(data, "weekly", "week", "secondary", "weekPercent")
    if session is None and week is None:
        raise ValueError("CodexBar JSON format not recognized")
    print(json.dumps({"session": session, "week": week, "error": ""}))
except Exception as exc:
    print(json.dumps({"session": None, "week": None, "error": str(exc)}))
