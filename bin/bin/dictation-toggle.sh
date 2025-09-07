#!/bin/bash

# Dictation toggle script for nerd-dictation
# Uses VOSK for offline speech recognition and wtype for text input

NERD_DICTATION_DIR="$HOME/.local/share/nerd-dictation"
PYTHON_VENV="$HOME/.local/share/nerd-dictation-venv/bin/python"
VOSK_MODEL="$HOME/.config/nerd-dictation/vosk-model-small-en-us-0.15"
STATUS_FILE="/tmp/dictation-status"

# Debug logging
echo "$(date): Dictation toggle called" >> /tmp/dictation-debug.log

# Check if dictation is running
if pgrep -f "nerd-dictation" > /dev/null; then
    # Stop dictation
    pkill -f "nerd-dictation"
    echo "inactive" > "$STATUS_FILE"
    dunstify "Dictation" "STOPPED" --icon=microphone-sensitivity-muted
    echo "$(date): Dictation stopped" >> /tmp/dictation-debug.log
else
    # Start dictation
    echo "active" > "$STATUS_FILE"
    dunstify "Dictation" "STARTED - Speak now!" --icon=microphone-sensitivity-high
    echo "$(date): Starting dictation" >> /tmp/dictation-debug.log
    
    # Start nerd-dictation in background  
    cd "$NERD_DICTATION_DIR" && \
    "$PYTHON_VENV" nerd-dictation begin \
        --vosk-model-dir="$VOSK_MODEL" \
        --simulate-input-tool=WTYPE \
        --timeout=30 \
        --continuous \
        >> /tmp/dictation-debug.log 2>&1 &
    
    # Don't auto-cleanup status - only change it when user manually stops
fi