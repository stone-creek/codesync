import requests
import argparse
import sys

parser = argparse.ArgumentParser(description="Authenticate and obtain a token.")
# parser.add_argument("--url", default="https://stonecreek.pro/api/v2/login", help="API authentication endpoint")
parser.add_argument("--url", required=True, help="API authentication endpoint")
parser.add_argument("--login", required=True, help="Username or email, created at Discord")
parser.add_argument("--password", required=True, help="Password")

args = parser.parse_args()

credentials = {
    "Login": args.login,
    "Password": args.password
}

try:
    # Ensure the URL concatenation doesn't result in double slashes
    endpoint = args.url.rstrip('/') + "/api/v2/login"
    response = requests.post(endpoint, json=credentials)

    # This raises an HTTPError if the status is 4xx or 5xx
    response.raise_for_status()

    data = response.json()
    token = data.get("Auth")
    
    if token:
        print(token)
    else:
        # Handle case where API returns 200 OK but no token in JSON
        print("Error: Authentication successful but no token found in response.", file=sys.stderr)
        sys.exit(1)

except requests.exceptions.HTTPError as http_err:
    print(f"HTTP error occurred: {http_err} - {response.text}", file=sys.stderr)
    sys.exit(1) # Signal failure to Bash
except Exception as err:
    print(f"Other error occurred: {err}", file=sys.stderr)
    sys.exit(1) # Signal failure to Bash