#!/usr/bin/env python3
"""Log in to the server and watch the working directory for file changes.
Standard library only (Python 3.6+).
"""
import getpass
import json
import sys
import tempfile
import time
import urllib.error
import urllib.request
from pathlib import Path

POLL_INTERVAL = 1  # seconds


def ask(label, default=None):
    prompt = f"{label} [{default}]: " if default else f"{label}: "
    return input(prompt).strip() or default


def login(server, user, password):
    url = server.rstrip("/") + "/api/v2/login"
    body = json.dumps({"login": user, "password": password}).encode("utf-8")
    req = urllib.request.Request(
        url, data=body, method="POST",
        headers={"Content-Type": "application/json", "Accept": "application/json"},
    )

    try:
        with urllib.request.urlopen(req, timeout=15) as resp:
            data = json.loads(resp.read().decode("utf-8"))
    except urllib.error.HTTPError as e:
        sys.exit(f"HTTP {e.code}: {e.read().decode('utf-8', 'replace')}")
    except urllib.error.URLError as e:
        sys.exit(f"Connection failed: {e.reason}")
    except json.JSONDecodeError:
        sys.exit("Server response is not valid JSON.")

    token = data.get("auth") if isinstance(data, dict) else None
    if not token:
        sys.exit(f"No 'auth' field in response: {data}")
    return token


def snapshot(watch_dir):
    return {
        str(p): p.stat().st_mtime
        for p in watch_dir.rglob("*")
        if p.is_file()
    }

def ordered_lua_files(watch_dir):
    files = sorted(watch_dir.glob("*.lua"))
    ordered = []
    for name in ("_commons.lua", "_utils.lua"):
        f = watch_dir / name
        if f in files:
            files.remove(f)
            ordered.append(f)
    ordered.extend(files)
    return ordered


def push_to_server(server, guid, token, temp_path):
    with open(temp_path, "r", encoding="utf-8") as f:
        sourcecode = f.read()

    url = server.rstrip("/") + "/api/v2/server/" + guid
    body = json.dumps({"sourcecode": sourcecode}).encode("utf-8")
    req = urllib.request.Request(
        url, data=body, method="PATCH",
        headers={
            "Content-Type": "application/json",
            "Accept": "application/json",
            "Authorization": f"Bearer {token}",
        },
    )

    try:
        with urllib.request.urlopen(req, timeout=15) as resp:
            print(f"Push succeeded (HTTP {resp.status})")
    except urllib.error.HTTPError as e:
        print(f"Push failed (HTTP {e.code}): {e.read().decode('utf-8', 'replace')}")
    except urllib.error.URLError as e:
        print(f"Push failed: {e.reason}")


TEMP_PATH = Path(tempfile.gettempdir()) / "livecode-server.lua"


def on_change(watch_dir, server, guid, token):
    with open(TEMP_PATH, "w", encoding="utf-8") as tmp:
        for f in ordered_lua_files(watch_dir):
            tmp.write(f.read_text(encoding="utf-8"))
            tmp.write("\n")
    print(f"Consolidated source written to {TEMP_PATH}")
    push_to_server(server, guid, token, TEMP_PATH)


def watch(watch_dir, server, guid, token):
    print(f"Watching {watch_dir} for changes...")
    last = snapshot(watch_dir)
    while True:
        time.sleep(POLL_INTERVAL)
        current = snapshot(watch_dir)
        if current != last:
            on_change(watch_dir, server, guid, token)
            last = current


def main():
    try:
        workdir = ask("Working directory", "development")
        server = ask("Server address", "http://localhost")
        guid = ask("Server GUID", "C1A7AB-live-server")
        user = ask("User name", "Steinbach")
        password = getpass.getpass("Password: ")
        if not password:
            sys.exit("Password is required.")

        token = login(server, user, password)

        watch_dir = Path(__file__).resolve().parent.parent / "servers" / workdir
        if not watch_dir.is_dir():
            sys.exit(f"Working directory not found: {watch_dir}")

        watch(watch_dir, server, guid, token)
    except KeyboardInterrupt:
        print()
        sys.exit(0)

if __name__ == "__main__":
    main()