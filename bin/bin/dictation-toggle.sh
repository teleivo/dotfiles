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
    local mic_volume
    mic_volume=$(pactl get-source-volume @DEFAULT_SOURCE@ | grep -oP '\d+%' | head -1 | tr -d '%')
    local mic_muted
    mic_muted=$(pactl get-source-mute @DEFAULT_SOURCE@ | awk '{print $2}')

    # Save sink state (volume and mute status)
    local sink_volume
    sink_volume=$(pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\d+%' | head -1 | tr -d '%')
    local sink_muted
    sink_muted=$(pactl get-sink-mute @DEFAULT_SINK@ | awk '{print $2}')
    local default_sink
    default_sink=$(pactl get-default-sink)

    # Save card profile if using headset
    local card_id
    card_id=$(get_headset_card_id)
    local current_profile=""
    if [[ -n "$card_id" ]]; then
        current_profile=$(pactl list cards | grep -A 50 "Card #$card_id" | grep "Active Profile:" | cut -d: -f2- | xargs)
    fi

    # Save state to file
    {
        echo "$card_id"
        echo "$current_profile"
        echo "$mic_volume"
        echo "$mic_muted"
        echo "$sink_volume"
        echo "$sink_muted"
        echo "$default_sink"
    } > "$AUDIO_STATE_FILE"

    echo "$(date): Saved audio state - Card: $card_id, Profile: $current_profile, Mic: $mic_volume%/$mic_muted, Sink: $sink_volume%/$sink_muted, Default: $default_sink" >> "$DEBUG_LOG"
}

setup_dictation_audio() {
    # Save current audio state first
    save_audio_state

    # Switch to duplex profile for microphone access (required for Avantree headset)
    local card_id
    card_id=$(get_headset_card_id)
    if [[ -n "$card_id" ]]; then
        pactl set-card-profile "$card_id" output:analog-stereo+input:mono-fallback
        echo "$(date): Set card profile to duplex for microphone access" >> "$DEBUG_LOG"
        # Wait for profile change to take effect
        sleep 0.5
    fi

    # For echo-cancel sources, we need to ensure the underlying physical source exists and is active
    local current_source
    current_source=$(pactl get-default-source)

    if [[ "$current_source" == *"echo_cancel"* ]]; then
        # Find and activate the underlying physical source
        local physical_source
        physical_source=$(pactl list sources | grep -A 2 "Name:.*alsa_input.*Avantree" | grep "Name:" | cut -d: -f2 | xargs)
        if [[ -n "$physical_source" ]]; then
            pactl set-source-volume "$physical_source" 100%
            pactl set-source-mute "$physical_source" 0
            echo "$(date): Setup dictation audio - Physical source $physical_source: 100% unmuted" >> "$DEBUG_LOG"
        else
            echo "$(date): Warning: No physical Avantree source found, trying default source" >> "$DEBUG_LOG"
        fi
    fi

    # Set microphone to 100% volume and unmute (for both virtual and physical sources)
    pactl set-source-volume @DEFAULT_SOURCE@ 100%
    pactl set-source-mute @DEFAULT_SOURCE@ 0

    echo "$(date): Setup dictation audio - Default source: 100% unmuted" >> "$DEBUG_LOG"
    return 0
}

restore_dictation_audio() {
    # Check if we have saved state
    if [[ ! -f "$AUDIO_STATE_FILE" ]]; then
        echo "$(date): No audio state file found, using basic restore" >> "$DEBUG_LOG"
        # Fallback to music profile
        local card_id
        card_id=$(get_headset_card_id)
        if [[ -n "$card_id" ]]; then
            pactl set-card-profile "$card_id" output:analog-stereo
        fi
        return
    fi

    # Read saved state
    local saved_card_id
    saved_card_id=$(sed -n '1p' "$AUDIO_STATE_FILE")
    local saved_profile
    saved_profile=$(sed -n '2p' "$AUDIO_STATE_FILE")
    local saved_mic_volume
    saved_mic_volume=$(sed -n '3p' "$AUDIO_STATE_FILE")
    local saved_mic_muted
    saved_mic_muted=$(sed -n '4p' "$AUDIO_STATE_FILE")
    local saved_sink_volume
    saved_sink_volume=$(sed -n '5p' "$AUDIO_STATE_FILE")
    local saved_sink_muted
    saved_sink_muted=$(sed -n '6p' "$AUDIO_STATE_FILE")
    local saved_default_sink
    saved_default_sink=$(sed -n '7p' "$AUDIO_STATE_FILE")

    # Restore profile (only if we have a saved profile)
    if [[ -n "$saved_card_id" && -n "$saved_profile" ]]; then
        pactl set-card-profile "$saved_card_id" "$saved_profile"
    fi

    # Restore default sink
    if [[ -n "$saved_default_sink" ]]; then
        pactl set-default-sink "$saved_default_sink"
    fi

    # Restore microphone state
    pactl set-source-volume @DEFAULT_SOURCE@ "${saved_mic_volume}%"
    pactl set-source-mute @DEFAULT_SOURCE@ "$saved_mic_muted"

    # Restore sink state
    pactl set-sink-volume @DEFAULT_SINK@ "${saved_sink_volume}%"
    pactl set-sink-mute @DEFAULT_SINK@ "$saved_sink_muted"

    echo "$(date): Restored audio state - Profile: $saved_profile, Mic: $saved_mic_volume%/$saved_mic_muted, Sink: $saved_sink_volume%/$saved_sink_muted, Default: $saved_default_sink" >> "$DEBUG_LOG"

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
    notify-send --urgency=low "Dictation" "STOPPED"
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

    notify-send --urgency=normal "Dictation" "STARTED - Speak now!"
    echo "$(date): Starting dictation" >> "$DEBUG_LOG"

    # Use the same audio source approach as the working loopback test
    local source_to_use
    source_to_use=$(pactl get-default-source)
    echo "$(date): Using audio source: $source_to_use" >> "$DEBUG_LOG"

    # Start nerd-dictation in background using wtype-slow (Slack not registering spaces fix)
    cd "$NERD_DICTATION_DIR" && \
    PATH="$HOME/code/dotfiles/bin/bin:$PATH" \
    "$PYTHON_VENV" nerd-dictation begin \
        --vosk-model-dir="$VOSK_MODEL" \
        --simulate-input-tool=WTYPE \
        --pulse-device-name="$source_to_use" \
        --timeout=30 \
        --continuous \
        >> "$DEBUG_LOG" 2>&1 &

    # Don't auto-cleanup status - only change it when user manually stops
fi