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
save_audio_state() {
    local default_sink=$(pactl get-default-sink)
    local card_id=""

    # Find and save current card and profile
    if [[ "$default_sink" == *"Avantree"* ]]; then
        card_id=$(pactl list cards short | grep Avantree | cut -f1)
    elif [[ "$default_sink" == *"Jabra"* ]]; then
        card_id=$(pactl list cards short | grep Jabra | cut -f1)
    else
        echo "$(date): No compatible headset found for state saving" >> "$DEBUG_LOG"
        return 1
    fi

    # Save current profile
    local current_profile=$(pactl list cards | grep -A 50 "Name: $(pactl list cards | grep -E "(Avantree|Jabra)" | cut -f2)" | grep "Active Profile:" | cut -d: -f2- | xargs)
    echo "$card_id" > "$AUDIO_STATE_FILE"
    echo "$current_profile" >> "$AUDIO_STATE_FILE"

    # Save microphone state (volume and mute status)
    local default_source=$(pactl get-default-source)
    local mic_volume=$(pactl list sources | grep -A 15 "Name: $default_source" | grep "Volume:" | head -1 | awk '{print $5}' | sed 's/%//')
    local mic_muted=$(pactl list sources | grep -A 15 "Name: $default_source" | grep "Mute:" | awk '{print $2}')

    echo "$mic_volume" >> "$AUDIO_STATE_FILE"
    echo "$mic_muted" >> "$AUDIO_STATE_FILE"

    echo "$(date): Saved audio state - Card: $card_id, Profile: $current_profile, Mic Volume: $mic_volume%, Muted: $mic_muted" >> "$DEBUG_LOG"
}

setup_dictation_audio() {
    # Save current audio state first
    if ! save_audio_state; then
        dunstify "Dictation Error" "No compatible headset found - connect Avantree or Jabra first" --icon=microphone-sensitivity-muted --urgency=critical
        return 1
    fi

    # Read saved card ID
    local card_id=$(head -1 "$AUDIO_STATE_FILE")

    # Switch to duplex profile for microphone access
    pactl set-card-profile "$card_id" output:analog-stereo+input:mono-fallback
    sleep 1

    # Set microphone to 100% volume and unmute
    local default_source=$(pactl get-default-source)
    pactl set-source-volume "$default_source" 100%
    pactl set-source-mute "$default_source" 0

    echo "$(date): Setup dictation audio - Card: $card_id, Mic: 100% unmuted" >> "$DEBUG_LOG"
    return 0
}

restore_dictation_audio() {
    # Check if we have saved state
    if [[ ! -f "$AUDIO_STATE_FILE" ]]; then
        echo "$(date): No audio state file found, using basic restore" >> "$DEBUG_LOG"
        # Fallback to basic restore
        local default_sink=$(pactl get-default-sink)
        local card_id=""
        if [[ "$default_sink" == *"Avantree"* ]]; then
            card_id=$(pactl list cards short | grep Avantree | cut -f1)
        elif [[ "$default_sink" == *"Jabra"* ]]; then
            card_id=$(pactl list cards short | grep Jabra | cut -f1)
        fi
        if [[ -n "$card_id" ]]; then
            pactl set-card-profile "$card_id" output:analog-stereo
        fi
        return
    fi

    # Read saved state
    local card_id=$(sed -n '1p' "$AUDIO_STATE_FILE")
    local saved_profile=$(sed -n '2p' "$AUDIO_STATE_FILE")
    local saved_mic_volume=$(sed -n '3p' "$AUDIO_STATE_FILE")
    local saved_mic_muted=$(sed -n '4p' "$AUDIO_STATE_FILE")

    # Restore profile
    pactl set-card-profile "$card_id" "$saved_profile"
    sleep 1

    # Restore microphone state
    local default_source=$(pactl get-default-source)
    pactl set-source-volume "$default_source" "${saved_mic_volume}%"
    pactl set-source-mute "$default_source" "$saved_mic_muted"

    echo "$(date): Restored audio state - Card: $card_id, Profile: $saved_profile, Mic Volume: $saved_mic_volume%, Muted: $saved_mic_muted" >> "$DEBUG_LOG"

    # Clean up state file
    rm -f "$AUDIO_STATE_FILE"
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
    
    restore_dictation_audio

    # Resume media after profile restoration to avoid playing through call profile
    if [[ -f "$DICTATION_RUN_DIR/media_was_playing" ]]; then
        playerctl play
        rm "$DICTATION_RUN_DIR/media_was_playing"
        echo "$(date): Resumed media playback" >> "$DEBUG_LOG"
    fi
else
    # Start dictation
    echo "active" > "$STATUS_FILE"
    
    # Pause any playing media using playerctl
    if playerctl status >/dev/null 2>&1 && [[ "$(playerctl status)" == "Playing" ]]; then
        playerctl pause
        touch "$DICTATION_RUN_DIR/media_was_playing"
        echo "$(date): Paused media: $(playerctl metadata --format '{{ artist }} - {{ title }}' 2>/dev/null || echo 'Unknown')" >> "$DEBUG_LOG"
    fi
    
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