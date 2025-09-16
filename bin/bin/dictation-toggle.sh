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
MIC_STATE_FILE="$DICTATION_RUN_DIR/mic_state"
AUDIO_STATE_FILE="$DICTATION_RUN_DIR/audio_state"
DEBUG_LOG="$DICTATION_RUN_DIR/debug.log"

# Uses WirePlumber configuration for device priority

# Ensure dictation runtime directory exists
mkdir -p "$DICTATION_RUN_DIR"

# Functions for audio device management
setup_dictation_audio() {
    # Get the current default sink (WirePlumber prioritizes devices automatically)
    local default_sink=$(pactl get-default-sink)

    # Find the card for the current default sink
    local card_id=""
    if [[ "$default_sink" == *"Avantree"* ]]; then
        card_id=$(pactl list cards short | grep Avantree | cut -f1)
        echo "$(date): Using Avantree as default audio device (card: $card_id)" >> "$DEBUG_LOG"
    elif [[ "$default_sink" == *"Jabra"* ]]; then
        card_id=$(pactl list cards short | grep Jabra | cut -f1)
        echo "$(date): Using Jabra as fallback audio device (card: $card_id)" >> "$DEBUG_LOG"
    else
        dunstify "Dictation Error" "No compatible headset found - connect Avantree or Jabra first" --icon=microphone-sensitivity-muted --urgency=critical
        echo "$(date): ERROR: No compatible headset found, default sink: $default_sink" >> "$DEBUG_LOG"
        return 1
    fi

    # Switch to duplex profile for microphone access
    pactl set-card-profile "$card_id" output:analog-stereo+input:mono-fallback
    sleep 1

    echo "$(date): Switched headset (card $card_id) to duplex mode for dictation" >> "$DEBUG_LOG"
    return 0
}

restore_dictation_audio() {
    # Get the current default sink to determine which card to restore
    local default_sink=$(pactl get-default-sink)
    local card_id=""

    if [[ "$default_sink" == *"Avantree"* ]]; then
        card_id=$(pactl list cards short | grep Avantree | cut -f1)
    elif [[ "$default_sink" == *"Jabra"* ]]; then
        card_id=$(pactl list cards short | grep Jabra | cut -f1)
    fi

    if [[ -n "$card_id" ]]; then
        pactl set-card-profile "$card_id" output:analog-stereo
        echo "$(date): Restored headset (card $card_id) to music mode (stereo-only)" >> "$DEBUG_LOG"
    fi
}

# Debug logging
echo "$(date): Dictation toggle called" >> "$DEBUG_LOG"

# Check if dictation is running
if pgrep -f "nerd-dictation" > /dev/null; then
    # Stop dictation
    pkill -f "nerd-dictation"
    echo "inactive" > "$STATUS_FILE"
    dunstify "Dictation" "STOPPED" --icon=microphone-sensitivity-muted
    echo "$(date): Dictation stopped" >> "$DEBUG_LOG"
    
    # Resume any paused audio
    if [[ -f "$DICTATION_RUN_DIR/paused_audio" ]]; then
        while read -r input_id; do
            if [[ -n "$input_id" ]]; then
                pactl set-sink-input-mute "$input_id" 0
            fi
        done < "$DICTATION_RUN_DIR/paused_audio"
        rm "$DICTATION_RUN_DIR/paused_audio"
        echo "$(date): Resumed audio playback" >> "$DEBUG_LOG"
    fi
    
    # Restore headset to music mode
    restore_dictation_audio
else
    # Start dictation
    echo "active" > "$STATUS_FILE"
    
    # Pause any playing audio
    pactl list sink-inputs short | while read -r input_id _; do
        if [[ -n "$input_id" ]]; then
            pactl set-sink-input-mute "$input_id" 1
            echo "$input_id" >> "$DICTATION_RUN_DIR/paused_audio"
        fi
    done
    echo "$(date): Paused audio playback" >> "$DEBUG_LOG"
    
    # Switch headset to duplex mode for dictation
    if ! setup_dictation_audio; then
        echo "inactive" > "$STATUS_FILE"
        exit 1
    fi
    
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