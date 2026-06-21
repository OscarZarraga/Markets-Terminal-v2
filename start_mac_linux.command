#!/usr/bin/env bash
# ============================================================
#  Unified Terminal — macOS / Linux launcher
#  Created by Oscar Zarraga Perez
#  Released under the MIT License.
# ------------------------------------------------------------
#  Runs the Python server in the background. The server opens
#  http://127.0.0.1:8787/ in your default browser automatically.
#  On macOS, the Terminal window self-closes a moment after the
#  server is up so you don't end up with a stray prompt.
# ============================================================
cd "$(dirname "$0")"

# --- 1. Python 3 must be installed. ---
if ! command -v python3 >/dev/null 2>&1; then
    MSG=$'Python 3 is required but was not found on your PATH.\n\nInstall it from python.org/downloads, or run:\n  macOS:  brew install python3\n  Linux:  sudo apt install python3'
    echo "$MSG"
    # Graphical dialog on macOS so the user sees the error even if they
    # double-clicked from Finder.
    if [[ "$OSTYPE" == "darwin"* ]]; then
        osascript -e "display dialog \"$MSG\" with title \"Unified Terminal\" buttons {\"OK\"} default button \"OK\" with icon stop" 2>/dev/null
    else
        read -r -p "Press Enter to close..."
    fi
    exit 1
fi

# --- 2. Stop any previous server on the same port so a relaunch ----
# doesn't double-bind. lsof ships with macOS; on Linux it's commonly
# installed. Silently skip if it's not present.
PORT=8787
if command -v lsof >/dev/null 2>&1; then
    OLD_PID=$(lsof -tiTCP:$PORT -sTCP:LISTEN 2>/dev/null | head -1)
    if [ -n "$OLD_PID" ]; then
        echo "Stopping previous server (pid $OLD_PID) on port $PORT..."
        kill "$OLD_PID" 2>/dev/null
        sleep 0.4
    fi
fi

# --- 3. Background launch. nohup + disown so it survives this script ----
# exiting. stdout/stderr go to terminal_server.log next to the script.
LOG="$(pwd)/terminal_server.log"
nohup python3 markets_data_api.py --port "$PORT" > "$LOG" 2>&1 &
SRV_PID=$!
disown "$SRV_PID" 2>/dev/null || true

echo
echo "========================================================"
echo "  Unified Terminal"
echo "  Created by Oscar Zarraga Perez"
echo "  Listening on http://127.0.0.1:$PORT/  (pid $SRV_PID)"
echo "  Logs:  $LOG"
echo "  Stop:  pkill -f 'markets_data_api.py'"
echo "========================================================"
echo

# Give the server a moment to bind, open the browser, and be ready
# before we close this Terminal window.
sleep 1.2

# --- 4. macOS: close this Terminal window so it doesn't sit empty. ---
# The Python server already opened the browser. On Linux we leave the
# window open so the user can see logs / Ctrl+C if needed.
if [[ "$OSTYPE" == "darwin"* ]]; then
    # Close any Terminal window whose title contains "start_mac"
    # (matches start_mac_linux.command). Best-effort; ignore errors.
    osascript -e 'tell application "Terminal" to close (every window whose name contains "start_mac")' 2>/dev/null &
fi

exit 0
