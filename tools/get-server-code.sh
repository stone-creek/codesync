#!/bin/bash

if [ -z "$auth_token" ]; then
    read -p "Login: " login
    read -s -p "Password: " password
    echo

    login_response=$(curl -s -X POST "http://localhost/api/v2/login" \
        -H "Content-Type: application/json" \
        -d "{\"login\": $(jq -Rn --arg v "$login" '$v'), \"password\": $(jq -Rn --arg v "$password" '$v')}")

    auth_token=$(echo "$login_response" | jq -r .auth)

    if [ -z "$auth_token" ] || [ "$auth_token" == "null" ]; then
        echo "Login failed: $login_response"
        exit 1
    fi
fi

echo "Fetches the sourcecode currently deployed on the local development server"
echo "and prints it to stdout."

fetch_from_server() {
    curl -s -X GET "http://localhost/api/v2/server/d2beef0b-5280-4e05-8c2e-abc36f29dd18" \
    -H "Authorization: Bearer $auth_token" \
    | jq -r .sourcecode
}

fetch_from_server
