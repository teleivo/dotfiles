#!/bin/bash

# Audio calls setup script
# Switches headset to duplex profile, unmutes mic at 100%, ensures output is unmuted at 30%

find_headset_card() {
    local card_id=""

    # Find compatible headset
    if pactl list cards short | grep -q Avantree; then
        card_id=$(pactl list cards short | grep Avantree | cut -f1)
    elif pactl list cards short | grep -q Jabra; then
        card_id=$(pactl list cards short | grep Jabra | cut -f1)
    else
        return 1
    fi

    echo "$card_id"
    return 0
}

setup_calls_audio() {
    local card_id=$(find_headset_card)
    if [[ -z "$card_id" ]]; then
        dunstify "Audio Calls" "No compatible headset found - connect Avantree or Jabra first" --icon=audio-headphones --urgency=critical
        return 1
    fi

    # Switch to duplex profile for microphone access
    pactl set-card-profile "$card_id" output:analog-stereo+input:mono-fallback
    sleep 1

    # Set microphone to 100% volume and unmute (exact same as dictation)
    local default_source=$(pactl get-default-source)
    pactl set-source-volume "$default_source" 100%
    pactl set-source-mute "$default_source" 0

    # Unmute default sink and ensure minimum 30% volume
    local default_sink=$(pactl get-default-sink)
    pactl set-sink-mute "$default_sink" 0
    local current_vol=$(pactl get-sink-volume "$default_sink" | grep -oP '\d+%' | head -1 | tr -d '%')
    if [[ "$current_vol" -lt 30 ]]; then
        pactl set-sink-volume "$default_sink" 30%
    fi

    dunstify "Audio Calls" "Calls mode activated - Mic: 100%, Output: unmuted" --icon=audio-headphones
    return 0
}

setup_calls_audio
