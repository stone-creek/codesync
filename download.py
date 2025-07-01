import requests
import argparse
import sys
import os

# Set up argument parser
parser = argparse.ArgumentParser(description="Retrieve the sourcecode of classes.")
parser.add_argument("--url", default="https://stonecreek.pro/api/v2/items", help="API items endpoint")
parser.add_argument("--auth", required=True, help="Authentication token")
parser.add_argument("--location", default="workspace", help="Directory with files")

args = parser.parse_args()

headers = {
    "Authorization": f"Bearer {args.auth}"
}

try:
    response = requests.get(args.url, headers=headers)

    response.raise_for_status()

    os.makedirs(args.location, exist_ok=True)

    data = response.json()
    for item in data["Items"]:

        if item.get("Sourcecode"):
            class_name = item["ItemHandle"]
            file_path = os.path.join(args.location, class_name)
            with open(file_path, "w") as f:
                f.write(item["Sourcecode"])

except requests.exceptions.HTTPError as http_err:
    print(f"HTTP error occurred: {http_err} - {response.text}")
except Exception as err:
    print(f"Other error occurred: {err}")

