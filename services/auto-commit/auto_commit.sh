#!/bin/bash

# === CONFIGURATION ===
WATCHED_FOLDER="$1"   # First argument: Path to Git repo
DEBOUNCE_TIME=60      # Time to wait after last change before committing
THROTTLE_TIME=300     # Force commit if changes continue
MAX_DELAY=600         # Absolute max delay before committing
BRANCH="main"         # Branch to push to (change if needed)

# === VALIDATION ===
if [ -z "$WATCHED_FOLDER" ]; then
    echo "Usage: $0 /path/to/repo"
    exit 1
fi

if [ ! -d "$WATCHED_FOLDER/.git" ]; then
    echo "Error: '$WATCHED_FOLDER' is not a valid Git repository."
    exit 1
fi

cd "$WATCHED_FOLDER" || exit

# === TRACK CHANGES ===
echo "Monitoring '$WATCHED_FOLDER' for file changes (excluding .git)..."

# Track last commit time and last change time
LAST_COMMIT_TIME=$(date +%s)
LAST_CHANGE_TIME=$(date +%s)
DEBOUNCE_TIMER_PID=0

commit_changes() {
    echo "Committing changes..."

    # Add changes
    git add -A

    # Create commit message
    COMMIT_MESSAGE="Auto-commit at $(date '+%Y-%m-%d %H:%M:%S')"

    # Commit
    git commit -m "$COMMIT_MESSAGE"

    # Push
    git push origin "$BRANCH"

    # Update last commit time
    LAST_COMMIT_TIME=$(date +%s)
    DEBOUNCE_TIMER_PID=0
}

debounce_commit() {
    echo "Starting debounce for $DEBOUNCE_TIME"
    while true; do
        sleep "$DEBOUNCE_TIME"
        
        CURRENT_TIME=$(date +%s)
        if (( CURRENT_TIME - LAST_CHANGE_TIME >= DEBOUNCE_TIME )); then
            commit_changes
            break
        fi
    done
}

# Monitor file changes using inotifywait (EXCLUDING .git folder)
inotifywait -m -r -e modify,create,delete --format "%w%f" --exclude '(^|/)\.git/' "$WATCHED_FOLDER" | while read -r FILE
do
    echo "Detected change in: $FILE"
    LAST_CHANGE_TIME=$(date +%s)

    # Restart debounce timer
    if [[ $DEBOUNCE_TIMER_PID -ne 0 ]]; then
        echo "Stopping debounce"
        kill "$DEBOUNCE_TIMER_PID" 2>/dev/null
    fi

    debounce_commit &  # Start debounce timer
    DEBOUNCE_TIMER_PID=$!

    # Force commit if throttle or max delay is exceeded
    CURRENT_TIME=$(date +%s)
    if (( CURRENT_TIME - LAST_COMMIT_TIME >= THROTTLE_TIME )); then
        echo "Throttle time reached"
        commit_changes
    elif (( CURRENT_TIME - LAST_COMMIT_TIME >= MAX_DELAY )); then
        echo "Max time reached"
        commit_changes
    fi
done
