#!/bin/bash

if [ -z "$auth_token" ]; then
    source initenv.sh
fi

WATCH_DIR="../workspace"
COMMAND1="python3 test.py"
COMMAND2="python3 upload.py --url=http://127.0.0.1:80 --auth=$auth_token"
INTERVAL=1  # Check every 2 seconds

get_snapshot() {
    find "$WATCH_DIR" -type f -printf "%p %T@\n" 2>/dev/null | sort
}

LAST_SNAPSHOT=$(get_snapshot)
eval "$COMMAND1"
echo "Watching $WATCH_DIR for changes..."

while true; do

    sleep "$INTERVAL"
    CURRENT_SNAPSHOT=$(get_snapshot)

    if [ "$CURRENT_SNAPSHOT" != "$LAST_SNAPSHOT" ]; then
        eval "$COMMAND1"
        if [ $? -eq 0 ]; then
            eval "$COMMAND2"
        else
            echo "Test did not pass, skipping upload."
        fi
        LAST_SNAPSHOT="$CURRENT_SNAPSHOT"
        echo "Watching $WATCH_DIR for changes..."
    fi
done
