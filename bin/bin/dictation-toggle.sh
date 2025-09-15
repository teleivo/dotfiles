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

# Audio device preferences for dictation
AVANTREE_MIC="Avantree C81(PC)"

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
    
    # Save current audio state
    local current_source=$(pactl get-default-source)
    local current_profile=$(pactl list cards | grep -A50 "Name: $avantree_card" | grep "Active Profile:" | cut -d: -f2 | xargs)
    echo "$current_source:$current_profile" > "$AUDIO_STATE_FILE"
    echo "$(date): Saved audio state - source: $current_source, profile: $current_profile" >> "$DEBUG_LOG"
    
    # Switch to duplex profile for microphone access
    pactl set-card-profile "$avantree_card" output:analog-stereo+input:mono-fallback
    sleep 1
    
    # Set Avantree as default source
    local avantree_id=$(wpctl status | grep -A20 "Sources:" | grep "$AVANTREE_MIC" | grep -o '[0-9]\+' | head -1)
    if [[ -n "$avantree_id" ]]; then
        wpctl set-default "$avantree_id"
        echo "$(date): Switched to Avantree microphone (ID: $avantree_id)" >> "$DEBUG_LOG"
        return 0
    else
        dunstify "Dictation Error" "Failed to configure Avantree microphone" --icon=microphone-sensitivity-muted --urgency=critical
        echo "$(date): ERROR: Failed to configure Avantree microphone" >> "$DEBUG_LOG"
        return 1
    fi
}

restore_dictation_audio() {
    if [[ -f "$AUDIO_STATE_FILE" ]]; then
        IFS=':' read -r prev_source prev_profile < "$AUDIO_STATE_FILE"
        local avantree_card=$(pactl list cards short | grep Avantree | cut -f1)
        
        # Restore Avantree profile if it was changed
        if [[ -n "$prev_profile" && "$prev_profile" != "" && -n "$avantree_card" ]]; then
            pactl set-card-profile "$avantree_card" "$prev_profile"
            echo "$(date): Restored Avantree profile to: $prev_profile" >> "$DEBUG_LOG"
            sleep 1
        fi
        
        # Restore default source
        if [[ -n "$prev_source" ]]; then
            pactl set-default-source "$prev_source"
            echo "$(date): Restored default source to: $prev_source" >> "$DEBUG_LOG"
        fi
        
        rm "$AUDIO_STATE_FILE"
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
    
    # Restore previous microphone mute state
    if [[ -f "$MIC_STATE_FILE" ]]; then
        IFS=':' read -r mic_name prev_mute < "$MIC_STATE_FILE"
        if [[ -n "$mic_name" && -n "$prev_mute" ]]; then
            pactl set-source-mute "$mic_name" "$prev_mute"
            echo "$(date): Restored mic $mic_name to mute state: $prev_mute" >> "$DEBUG_LOG"
        fi
        rm "$MIC_STATE_FILE"
    fi
    
    # Restore audio devices and profiles
    restore_dictation_audio
else
    # Start dictation
    echo "active" > "$STATUS_FILE"
    
    # Setup optimal audio device for dictation
    if ! setup_dictation_audio; then
        echo "inactive" > "$STATUS_FILE"
        exit 1
    fi
    
    # Get current default microphone and save mute state
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