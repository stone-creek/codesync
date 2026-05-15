#!/usr/bin/env bash

read -p "Enter Username (default:Steinbach): " username
username="${username:-Steinbach}"
read -sp "Enter Password: " password
echo ""

auth_output=$(python3 auth.py --url=http://127.0.0.1:80 --login="$username" --password="$password")

if [ $? -eq 0 ] && [ -n "$auth_output" ]; then
    export auth_token="$auth_output"
    echo "Success: Auth token exported"
else
    echo "Error: Authentication failed or returned no token." >&2
    exit 1
fi