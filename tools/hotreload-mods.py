#!/usr/bin/env python3
"""Log in to the server and watch the working directory for file changes.
Standard library only (Python 3.6+).
"""
import getpass
import hashlib
import json
import sys
import time
import urllib.error
import urllib.parse
import urllib.request
from pathlib import Path

POLL_INTERVAL = 1  # seconds
SERVER_GUIDS = ["C1A7AB-live-server", "D2BEEF-dev-server"]
SERVER_ADDRESSES = ["https://stonecreek.pro", "http://localhost"]

def ask(label, default=None):
    prompt = f"{label} [{default}]: " if default else f"{label}: "
    return input(prompt).strip() or default


def choose(label, options, default=0):
    for i, option in enumerate(options, 1):
        print(f"  {i}) {option}")
    while True:
        answer = ask(label, str(default + 1))
        if answer.isdigit() and 1 <= int(answer) <= len(options):
            return options[int(answer) - 1]
        print(f"Please enter a number between 1 and {len(options)}.")


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


def get_hashes(server, token):
    """Fetch all items and return {itemHandle: md5 hex digest of sourcecode}."""
    url = server.rstrip("/") + "/api/v2/items"
    req = urllib.request.Request(
        url, method="GET",
        headers={"Accept": "application/json", "Authorization": f"Bearer {token}"},
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

    hashes = {}
    for item in data.get("items", []):
        sourcecode = item.get("sourcecode") or ""
        hashes[item["itemHandle"]] = hashlib.md5(sourcecode.encode("utf-8")).hexdigest()
    return hashes


def local_hashes(watch_dir):
    """Return {filename: md5 hex digest of contents}, hashed the same way as get_hashes."""
    return {
        p.name: hashlib.md5(p.read_text(encoding="utf-8").encode("utf-8")).hexdigest()
        for p in watch_dir.iterdir()
        if p.is_file()
    }


def on_change(watch_dir, server, token, changed):
    """PATCH the sourcecode of each changed file to /api/v2/item/{itemHandle}. Returns the names that were uploaded."""
    uploaded = []
    for name in sorted(changed):
        url = f"{server.rstrip('/')}/api/v2/item/{urllib.parse.quote(name, safe='')}"
        sourcecode = (watch_dir / name).read_text(encoding="utf-8")
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
                print(f"Uploaded {name} (HTTP {resp.status})")
            uploaded.append(name)
        except urllib.error.HTTPError as e:
            print(f"Upload of {name} failed (HTTP {e.code}): {e.read().decode('utf-8', 'replace')}")
        except urllib.error.URLError as e:
            print(f"Upload of {name} failed: {e.reason}")
    return uploaded


def watch(watch_dir, server, guid, token, hashes):
    print(f"Watching {watch_dir} for changes...")
    known = dict(hashes)
    unknown = set()  # local files with no matching item on the server, warned about once
    while True:
        current = local_hashes(watch_dir)
        changed = []
        for name, digest in current.items():
            if name not in hashes:
                if name not in unknown:
                    print(f"Skipping {name}: no item with that handle on the server.")
                    unknown.add(name)
            elif known.get(name) != digest:
                changed.append(name)
        if changed:
            print(f"Changed: {', '.join(sorted(changed))}")
            for name in on_change(watch_dir, server, token, changed):
                known[name] = current[name]
        time.sleep(POLL_INTERVAL)


def main():
    try:
        workdir = ask("Working directory", "mods")
        server = choose("Server address", SERVER_ADDRESSES)
        guid = choose("Server GUID", SERVER_GUIDS)
        user = ask("User name", "Steinbach")
        password = getpass.getpass("Password: ")
        if not password:
            sys.exit("Password is required.")

        token = login(server, user, password)

        watch_dir = Path(__file__).resolve().parent.parent / workdir
        if not watch_dir.is_dir():
            sys.exit(f"Working directory not found: {watch_dir}")

        hashes = get_hashes(server, token)
        # for handle, digest in sorted(hashes.items()):
        #     print(f"{digest}  {handle}")

        watch(watch_dir, server, guid, token, hashes)
    except KeyboardInterrupt:
        print()
        sys.exit(0)

if __name__ == "__main__":
    main()