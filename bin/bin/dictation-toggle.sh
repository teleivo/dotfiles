#!/bin/bash

# Dictation toggle script for nerd-dictation
# Uses VOSK for offline speech recognition and wtype for text input

# Source common audio utilities
source "$(dirname "$0")/audio-utils"

NERD_DICTATION_DIR="$HOME/.local/share/nerd-dictation"
PYTHON_VENV="$HOME/.local/share/nerd-dictation-venv/bin/python"
# VOSK Models - lgraph supports dynamic vocabulary modification for technical terms
VOSK_MODEL="$HOME/.config/nerd-dictation/vosk-model-en-us-0.22-lgraph"
# VOSK_MODEL="$HOME/.config/nerd-dictation/vosk-model-small-en-us-0.15"  # Fallback: smaller/faster model
DICTATION_RUN_DIR="${XDG_RUNTIME_DIR:-/run/user/$UID}/dictation"
STATUS_FILE="$DICTATION_RUN_DIR/status"
AUDIO_STATE_FILE="$DICTATION_RUN_DIR/audio_state"
DEBUG_LOG="$DICTATION_RUN_DIR/debug.log"

# Ensure dictation runtime directory exists
mkdir -p "$DICTATION_RUN_DIR"

# Save current audio state
save_audio_state() {
    # Save microphone state (volume and mute status)
    local mic_volume=$(pactl get-source-volume @DEFAULT_SOURCE@ | grep -oP '\d+%' | head -1 | tr -d '%')
    local mic_muted=$(pactl get-source-mute @DEFAULT_SOURCE@ | awk '{print $2}')

    # Save card profile if using headset
    local card_id=$(get_headset_card_id)
    local current_profile=""
    if [[ -n "$card_id" ]]; then
        current_profile=$(pactl list cards | grep -A 50 "Card #$card_id" | grep "Active Profile:" | cut -d: -f2- | xargs)
    fi

    # Save state to file
    echo "$card_id" > "$AUDIO_STATE_FILE"
    echo "$current_profile" >> "$AUDIO_STATE_FILE"
    echo "$mic_volume" >> "$AUDIO_STATE_FILE"
    echo "$mic_muted" >> "$AUDIO_STATE_FILE"

    echo "$(date): Saved audio state - Card: $card_id, Profile: $current_profile, Mic Volume: $mic_volume%, Muted: $mic_muted" >> "$DEBUG_LOG"
}

setup_dictation_audio() {
    # Save current audio state first
    save_audio_state

    # Switch to duplex profile for microphone access (only for headsets)
    local card_id=$(get_headset_card_id)
    if [[ -n "$card_id" ]]; then
        pactl set-card-profile "$card_id" output:analog-stereo+input:mono-fallback
        sleep 1
    fi

    # Set microphone to 100% volume and unmute
    pactl set-source-volume @DEFAULT_SOURCE@ 100%
    pactl set-source-mute @DEFAULT_SOURCE@ 0

    echo "$(date): Setup dictation audio - Mic: 100% unmuted" >> "$DEBUG_LOG"
    return 0
}

restore_dictation_audio() {
    # Check if we have saved state
    if [[ ! -f "$AUDIO_STATE_FILE" ]]; then
        echo "$(date): No audio state file found, using basic restore" >> "$DEBUG_LOG"
        # Fallback to music profile
        local card_id=$(get_headset_card_id)
        if [[ -n "$card_id" ]]; then
            pactl set-card-profile "$card_id" output:analog-stereo
        fi
        return
    fi

    # Read saved state
    local saved_card_id=$(sed -n '1p' "$AUDIO_STATE_FILE")
    local saved_profile=$(sed -n '2p' "$AUDIO_STATE_FILE")
    local saved_mic_volume=$(sed -n '3p' "$AUDIO_STATE_FILE")
    local saved_mic_muted=$(sed -n '4p' "$AUDIO_STATE_FILE")

    # Restore profile (only if we have a saved profile)
    if [[ -n "$saved_card_id" && -n "$saved_profile" ]]; then
        pactl set-card-profile "$saved_card_id" "$saved_profile"
        sleep 1
    fi

    # Restore microphone state
    pactl set-source-volume @DEFAULT_SOURCE@ "${saved_mic_volume}%"
    pactl set-source-mute @DEFAULT_SOURCE@ "$saved_mic_muted"

    echo "$(date): Restored audio state - Profile: $saved_profile, Mic Volume: $saved_mic_volume%, Muted: $saved_mic_muted" >> "$DEBUG_LOG"

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

    # Resume media after profile restoration
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

    # Setup audio for dictation
    setup_dictation_audio

    dunstify "Dictation" "STARTED - Speak now!" --icon=microphone-sensitivity-high
    echo "$(date): Starting dictation" >> "$DEBUG_LOG"

    # Start nerd-dictation in background using wtype-slow (Slack not registering spaces fix)
    cd "$NERD_DICTATION_DIR" && \
    PATH="$HOME/code/dotfiles/bin/bin:$PATH" \
    "$PYTHON_VENV" nerd-dictation begin \
        --vosk-model-dir="$VOSK_MODEL" \
        --simulate-input-tool=WTYPE \
        --timeout=30 \
        --continuous \
        >> "$DEBUG_LOG" 2>&1 &

    # Don't auto-cleanup status - only change it when user manually stops
fi