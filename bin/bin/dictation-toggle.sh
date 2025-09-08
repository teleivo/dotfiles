#!/bin/bash

# Dictation toggle script for nerd-dictation
# Uses VOSK for offline speech recognition and wtype for text input

NERD_DICTATION_DIR="$HOME/.local/share/nerd-dictation"
PYTHON_VENV="$HOME/.local/share/nerd-dictation-venv/bin/python"
VOSK_MODEL="$HOME/.config/nerd-dictation/vosk-model-small-en-us-0.15"
STATUS_FILE="/tmp/dictation-status"
MIC_STATE_FILE="/tmp/dictation-mic-state"

# Debug logging
echo "$(date): Dictation toggle called" >> /tmp/dictation-debug.log

# Check if dictation is running
if pgrep -f "nerd-dictation" > /dev/null; then
    # Stop dictation
    pkill -f "nerd-dictation"
    echo "inactive" > "$STATUS_FILE"
    dunstify "Dictation" "STOPPED" --icon=microphone-sensitivity-muted
    echo "$(date): Dictation stopped" >> /tmp/dictation-debug.log
    
    # Restore previous microphone mute state
    if [[ -f "$MIC_STATE_FILE" ]]; then
        IFS=':' read -r mic_name prev_mute < "$MIC_STATE_FILE"
        if [[ -n "$mic_name" && -n "$prev_mute" ]]; then
            pactl set-source-mute "$mic_name" "$prev_mute"
            echo "$(date): Restored mic $mic_name to mute state: $prev_mute" >> /tmp/dictation-debug.log
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
    echo "$(date): Saved mic state - $DEFAULT_MIC:$CURRENT_MUTE" >> /tmp/dictation-debug.log
    
    # Unmute microphone for dictation
    pactl set-source-mute "$DEFAULT_MIC" 0
    echo "$(date): Unmuted microphone: $DEFAULT_MIC" >> /tmp/dictation-debug.log
    
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