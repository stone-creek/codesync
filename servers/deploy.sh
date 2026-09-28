#!/usr/bin/env bash

echo "Consolidates the files inside the specified directory and "
echo "upload the result to the 'sourcecode' field of a server."

TEMP_FILE="/tmp/temp-server-code.lua"
RESPONSE_FILE="/tmp/temp-server-response.json"
trap 'rm -f "$TEMP_FILE" "$RESPONSE_FILE"' EXIT

read -p "Working directory (default: development): " work_dir
work_dir="${work_dir:-development}"
read -p "Server address (default: https://stonecreek.pro): " server_address
server_address="${server_address:-https://stonecreek.pro}"
read -p "Server guid (default: C1A7AB-live-server): " server_guid 
server_guid="${server_guid:-C1A7AB-live-server}"
read -p "Enter username (default: Steinbach): " username
username="${username:-Steinbach}"
read -sp "Enter password: " password
echo ""

# Authenticate

login_payload=$(jq -n --arg login "$username" --arg password "$password" '{login: $login, password: $password}')

auth_token=$(curl -s -X POST "$server_address/api/v2/login" \
    -H "Content-Type: application/json" \
    -d "$login_payload" \
    | jq -r '.auth')

if [ $? -eq 0 ] && [ -n "$auth_token" ] && [ "$auth_token" != "null" ]; then
    echo "Authentication successful."
else
    echo "Error: Authentication failed or returned no token." >&2
    exit 1
fi

# Consolidate

for required in "_commons.lua" "_utils.lua"; do
    if [ ! -f "$work_dir/$required" ]; then
        echo "Error: $work_dir/$required not found." >&2
        exit 1
    fi
done

cat "$work_dir/_commons.lua" > "$TEMP_FILE"
echo >> "$TEMP_FILE"
cat "$work_dir/_utils.lua" >> "$TEMP_FILE"
echo >> "$TEMP_FILE"

find "$work_dir" -maxdepth 1 -type f -name "*.lua" \
    ! -name "_commons.lua" ! -name "_utils.lua" \
    | sort \
    | while IFS= read -r f; do
        cat "$f"
        echo
        done >> "$TEMP_FILE"

# Push to server

http_status=$(curl -s -o "$RESPONSE_FILE" -w "%{http_code}" -X PATCH "${server_address}/api/v2/server/${server_guid}" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $auth_token" \
    -d "{\"sourcecode\": $(jq -Rs . < "$TEMP_FILE")}")

if [ "$http_status" -ge 200 ] && [ "$http_status" -lt 300 ]; then
    echo "Upload successful."
else
    echo "Error: Upload failed (HTTP $http_status)." >&2
    cat "$RESPONSE_FILE" >&2
    exit 1
fi