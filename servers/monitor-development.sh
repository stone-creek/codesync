#!/bin/bash

WATCH_DIR="development"
INTERVAL=1  # Check every second

consolidate() {
    cat "$WATCH_DIR/_commons.lua" > Concatenate.lua
    echo >> Concatenate.lua
    cat "$WATCH_DIR/_utils.lua" >> Concatenate.lua
    echo >> Concatenate.lua

    find "$WATCH_DIR" -maxdepth 1 -type f -name "*.lua" \
        ! -name "commons.lua" ! -name "utils.lua" \
        | sort \
        | while IFS= read -r f; do
            cat "$f"
            echo
            done >> Concatenate.lua
}

get_snapshot() {
    find "$WATCH_DIR" -type f -printf "%p %T@\n" 2>/dev/null | sort
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
    fi
done