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

# Simplified: Only use Avantree for everything

# Ensure dictation runtime directory exists
mkdir -p "$DICTATION_RUN_DIR"

# Functions for audio device management
setup_dictation_audio() {
    # Check if Avantree is available
    local avantree_card=$(pactl list cards short | grep Avantree | cut -f1)
    if [[ -z "$avantree_card" ]]; then
        dunstify "Dictation Error" "Avantree C81 not found - connect device first" --icon=microphone-sensitivity-muted --urgency=critical
        echo "$(date): ERROR: Avantree C81 not found" >> "$DEBUG_LOG"
        return 1
    fi
    
    # Switch to duplex profile for microphone access
    pactl set-card-profile "$avantree_card" output:analog-stereo+input:mono-fallback
    sleep 1
    
    # Set Avantree microphone as default source for dictation
    pactl set-default-source alsa_input.usb-Avantree_Avantree_C81_PC__6502DEFA4F2179BD8F47-02.mono-fallback
    
    echo "$(date): Switched Avantree to duplex mode and set as default source" >> "$DEBUG_LOG"
    return 0
}

restore_dictation_audio() {
    # Switch Avantree back to music mode (stereo-only)
    local avantree_card=$(pactl list cards short | grep Avantree | cut -f1)
    if [[ -n "$avantree_card" ]]; then
        pactl set-card-profile "$avantree_card" output:analog-stereo
        echo "$(date): Restored Avantree to music mode (stereo-only)" >> "$DEBUG_LOG"
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
    
    # Restore Avantree to music mode
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
    
    # Switch Avantree to duplex mode for dictation
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