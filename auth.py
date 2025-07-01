import requests
import argparse
import sys

# Set up argument parser
parser = argparse.ArgumentParser(description="Authenticate and obtain a token.")
parser.add_argument("--url", default="https://stonecreek.pro/api/v2/login", help="API authentication endpoint")
parser.add_argument("--login", required=True, help="Username or email, created at Discord")
parser.add_argument("--password", required=True, help="Password")

args = parser.parse_args()

# Prepare credentials
credentials = {
    "Login": args.login,
    "Password": args.password
}

try:
    response = requests.post(args.url, json=credentials)

    response.raise_for_status()

    data = response.json()
    token = data.get("Auth")  # or data["access_token"] depending on the API
    print(token)

except requests.exceptions.HTTPError as http_err:
    print(f"HTTP error occurred: {http_err} - {response.text}")
except Exception as err:
    print(f"Other error occurred: {err}")

