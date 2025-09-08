#!/bin/bash

# Dictation toggle script for nerd-dictation
# Uses VOSK for offline speech recognition and wtype for text input

NERD_DICTATION_DIR="$HOME/.local/share/nerd-dictation"
PYTHON_VENV="$HOME/.local/share/nerd-dictation-venv/bin/python"
# VOSK Models - lgraph supports dynamic vocabulary modification for technical terms
VOSK_MODEL="$HOME/.config/nerd-dictation/vosk-model-en-us-0.22-lgraph"
# VOSK_MODEL="$HOME/.config/nerd-dictation/vosk-model-small-en-us-0.15"  # Fallback: smaller/faster model
DICTATION_RUN_DIR="${XDG_RUNTIME_DIR:-/run/user/$UID}/dictation"
STATUS_FILE="$DICTATION_RUN_DIR/status"
MIC_STATE_FILE="$DICTATION_RUN_DIR/state"
DEBUG_LOG="$DICTATION_RUN_DIR/debug.log"

# Ensure dictation runtime directory exists
mkdir -p "$DICTATION_RUN_DIR"

# Debug logging
echo "$(date): Dictation toggle called" >> "$DEBUG_LOG"

# Check if dictation is running
if pgrep -f "nerd-dictation" > /dev/null; then
    # Stop dictation
    pkill -f "nerd-dictation"
    echo "inactive" > "$STATUS_FILE"
    dunstify "Dictation" "STOPPED" --icon=microphone-sensitivity-muted
    echo "$(date): Dictation stopped" >> "$DEBUG_LOG"
    
    # Restore previous microphone mute state
    if [[ -f "$MIC_STATE_FILE" ]]; then
        IFS=':' read -r mic_name prev_mute < "$MIC_STATE_FILE"
        if [[ -n "$mic_name" && -n "$prev_mute" ]]; then
            pactl set-source-mute "$mic_name" "$prev_mute"
            echo "$(date): Restored mic $mic_name to mute state: $prev_mute" >> "$DEBUG_LOG"
        fi
        rm "$MIC_STATE_FILE"
    fi
else
    # Start dictation
    echo "active" > "$STATUS_FILE"
    
    # Get default microphone and save current mute state
    DEFAULT_MIC=$(pactl get-default-source)
    CURRENT_MUTE=$(pactl get-source-mute "$DEFAULT_MIC" | grep -o "yes\|no")
    
    # Convert mute state to numeric for pactl command
    MUTE_NUMERIC="0"
    if [[ "$CURRENT_MUTE" == "yes" ]]; then
        MUTE_NUMERIC="1"
    fi
    
    # Save current state for restoration later
    echo "$DEFAULT_MIC:$MUTE_NUMERIC" > "$MIC_STATE_FILE"
    echo "$(date): Saved mic state - $DEFAULT_MIC:$CURRENT_MUTE" >> "$DEBUG_LOG"
    
    # Unmute microphone for dictation
    pactl set-source-mute "$DEFAULT_MIC" 0
    echo "$(date): Unmuted microphone: $DEFAULT_MIC" >> "$DEBUG_LOG"
    
    dunstify "Dictation" "STARTED - Speak now!" --icon=microphone-sensitivity-high
    echo "$(date): Starting dictation" >> "$DEBUG_LOG"
    
    # Start nerd-dictation in background  
    cd "$NERD_DICTATION_DIR" && \
    "$PYTHON_VENV" nerd-dictation begin \
        --vosk-model-dir="$VOSK_MODEL" \
        --simulate-input-tool=WTYPE \
        --timeout=30 \
        --continuous \
        >> "$DEBUG_LOG" 2>&1 &
    
    # Don't auto-cleanup status - only change it when user manually stops
fi