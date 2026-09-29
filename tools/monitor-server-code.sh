#!/bin/bash

if [ -z "$auth_token" ]; then
    source initenv.sh
fi

WATCH_DIR="./../servers/development"
TEMP_FILE="/tmp/temp-server-code.lua"

trap 'rm -f "$TEMP_FILE"' EXIT

INTERVAL=1  # Check every second

consolidate() {
    cat "$WATCH_DIR/_commons.lua" > $TEMP_FILE
    echo >> $TEMP_FILE
    cat "$WATCH_DIR/_utils.lua" >> $TEMP_FILE
    echo >> $TEMP_FILE

    find "$WATCH_DIR" -maxdepth 1 -type f -name "*.lua" \
        ! -name "_commons.lua" ! -name "_utils.lua" \
        | sort \
        | while IFS= read -r f; do
            cat "$f"
            echo
            done >> $TEMP_FILE
}

get_snapshot() {
    find "$WATCH_DIR" -type f -printf "%p %T@\n" 2>/dev/null | sort
}

push_to_server() {
    status=$(curl -s -o /dev/null -w "%{http_code}" -X PATCH "http://localhost/api/v2/server/C1A7AB-live-server" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $auth_token" \
    -d "{\"sourcecode\": $(jq -Rs . "$TEMP_FILE")}")
    if [ "$status" -ge 400 ]; then
        echo "Push failed (HTTP $status)"
    else
        echo "Push succeeded (HTTP $status)"
    fi
}

echo "Watching $WATCH_DIR for changes..."
LAST_SNAPSHOT=$(get_snapshot)

while true; do
    sleep "$INTERVAL"
    CURRENT_SNAPSHOT=$(get_snapshot)

    if [ "$CURRENT_SNAPSHOT" != "$LAST_SNAPSHOT" ]; then
        echo "Changes detected, consolidating..."
        consolidate
        LAST_SNAPSHOT="$CURRENT_SNAPSHOT"
        push_to_server
    fi
done