#!/bin/bash

source initenv.sh

WATCH_DIR="workspace"
COMMAND1="python3 test.py"
COMMAND2="python3 upload.py --url=http://192.168.50.70:8088 --auth=$auth_token"
INTERVAL=1  # Check every 2 seconds

get_snapshot() {
    find "$WATCH_DIR" -type f -printf "%p %T@\n" 2>/dev/null | sort
}

echo "Watching $WATCH_DIR for changes..."
LAST_SNAPSHOT=$(get_snapshot)

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
    fi
done
