import requests
import argparse
import sys
import os
import difflib

# Set up argument parser
parser = argparse.ArgumentParser(description="Compare code from classes at location to the server.")
# parser.add_argument("--url", default="https://stonecreek.pro/api/v2/items", help="API items endpoint")
parser.add_argument("--url", required=True, help="API items endpoint")
parser.add_argument("--auth", required=True, help="Authentication token")
parser.add_argument("--location", default="workspace", help="Directory with files")

args = parser.parse_args()

headers = {
    "Authorization": f"Bearer {args.auth}"
}

try:
    response = requests.get(args.url + "/api/v2/items", headers=headers)
    response.raise_for_status()

    data = response.json()
    
    remote_files = {}
    local_files = {}

    # Load remote files into the dictionary (key=class name)
    for item in data["Items"]:
        if item.get("Sourcecode"):
            class_name = item["ItemHandle"]
            remote_files[class_name]=item["Sourcecode"]

    # Load local files into the dictionary (key=filename)
    for filename in os.listdir(args.location):
        file_path = os.path.join(args.location, filename)
        if os.path.isfile(file_path):
            with open(file_path, "r", encoding="utf-8") as f:
                local_files[filename] = f.read()

    # Get all filenames
    all_filenames = set(remote_files) | set(local_files)

    # Compare files
    for filename in sorted(all_filenames):
        content1 = remote_files.get(filename)
        content2 = local_files.get(filename)

        if content1 is None:
            print(f"\nFile added locally: {filename}")
        elif content2 is None:
            print(f"\nFile removed locally: {filename}")
        elif content1 != content2:
            print(f"\nDiff for: {filename}")
            diff = difflib.unified_diff(
                content1.splitlines(),
                content2.splitlines(),
                fromfile=f"remote/{filename}",
                tofile=f"local/{filename}",
                lineterm=""
            )
            for line in diff:
                print(line)

except requests.exceptions.HTTPError as http_err:
    print(f"HTTP error occurred: {http_err} - {response.text}")
except Exception as err:
    print(f"Other error occurred: {err}")

