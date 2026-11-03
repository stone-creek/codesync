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


def snapshot(watch_dir):
    return {
        str(p): p.stat().st_mtime
        for p in watch_dir.rglob("*")
        if p.is_file()
    }

def push_to_server(server, guid, token, temp_path):

    print(f"Push to server called.")
    # with open(temp_path, "r", encoding="utf-8") as f:
    #     sourcecode = f.read()

    # url = server.rstrip("/") + "/api/v2/server/" + guid
    # body = json.dumps({"sourcecode": sourcecode}).encode("utf-8")
    # req = urllib.request.Request(
    #     url, data=body, method="PATCH",
    #     headers={
    #         "Content-Type": "application/json",
    #         "Accept": "application/json",
    #         "Authorization": f"Bearer {token}",
    #     },
    # )

    # try:
    #     with urllib.request.urlopen(req, timeout=15) as resp:
    #         print(f"Push succeeded (HTTP {resp.status})")
    # except urllib.error.HTTPError as e:
    #     print(f"Push failed (HTTP {e.code}): {e.read().decode('utf-8', 'replace')}")
    # except urllib.error.URLError as e:
    #     print(f"Push failed: {e.reason}")


TEMP_PATH = Path(tempfile.gettempdir()) / "livecode-mods.lua"

def on_change(watch_dir, server, guid, token):
    with open(TEMP_PATH, "w", encoding="utf-8") as tmp:
        files = sorted(watch_dir.glob("*.lua"))
        for f in files:
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

        watch(watch_dir, server, guid, token)
    except KeyboardInterrupt:
        print()
        sys.exit(0)

if __name__ == "__main__":
    main()








# import requests
# import argparse
# import sys
# import os

# # Set up argument parser
# parser = argparse.ArgumentParser(description="Compare code from classes at location to the server and upload.")
# # parser.add_argument("--url", default="https://stonecreek.pro/api/v2/items", help="API items endpoint")
# parser.add_argument("--url", required=True, help="API items endpoint")
# parser.add_argument("--auth", required=True, help="Authentication token")
# parser.add_argument("--location", default="../workspace", help="Directory with files")

# args = parser.parse_args()

# headers = {
#     "Authorization": f"Bearer {args.auth}"
# }

# try:
#     response = requests.get(args.url + "/api/v2/items", headers=headers)
#     response.raise_for_status()

#     data = response.json()
    
#     remote_jsons = {}
#     remote_files = {}
#     local_files = {}

#     # Load remote files into the dictionary (key=class name)
#     for item in data["items"]:
#         class_name = item["itemHandle"]
#         remote_jsons[class_name]=item
#         remote_files[class_name]=''
#         if item.get("sourcecode"):
#             remote_files[class_name]=item["sourcecode"]

#     # Load local files into the dictionary (key=filename)
#     for filename in os.listdir(args.location):
#         file_path = os.path.join(args.location, filename)
#         if os.path.isfile(file_path):
#             with open(file_path, "r", encoding="utf-8") as f:
#                 local_files[filename] = f.read()

#     # Get all filenames
#     all_filenames = set(remote_files) | set(local_files)

#     # Compare files
#     for filename in sorted(all_filenames):
#         # print(f"Processing: {filename}")
#         content_remote = remote_files.get(filename)
#         content_local = local_files.get(filename)

#         if content_remote is None:
#             raise Exception(f"File added locally but item not found: {filename}")

#         elif content_local is None:
#             if content_remote != '':
#                 print(f"File removed locally: {filename}")

#         elif content_remote != content_local:

#             upload_data = remote_jsons.get(filename)
#             # print(f"Uploading... {upload_data}")
#             upload_data["sourcecode"] = content_local
#             del upload_data["id"]
#             del upload_data["createdAt"]
#             del upload_data["updatedAt"]

#             print(f"Updating file: {filename}...")
#             response = requests.put(args.url + "/api/v2/item", json=upload_data, headers=headers)
#             print(f"File {filename} successfully updated.")
#             response.raise_for_status()
        

# except requests.exceptions.HTTPError as http_err:
#     print(f"HTTP error occurred: {http_err} - {response.text}")
# except Exception as err:
#     print(f"Other error occurred: {err}")

