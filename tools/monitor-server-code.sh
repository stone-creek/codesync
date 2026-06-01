#!/bin/bash

if [ -z "$auth_token" ]; then
    source initenv.sh
fi

echo "Monitors the directory ./servers/development for file changes,"
echo "and when changes are detected, will upload as a PATCH to the"
echo "local development server. Use ./tools/upload-server-code-production"
echo "to move the contents of ./servers/development files to production."

WATCH_DIR="./../servers/development"
TEMP_FILE="/tmp/temp-server-code.lua"
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
    curl -X PATCH "http://localhost/api/v2/server/d2beef0b-5280-4e05-8c2e-abc36f29dd18" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $auth_token" \
    -d "{\"Sourcecode\": $(cat $TEMP_FILE | jq -Rs .)}"
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