#!/bin/bash

# Audio music setup script
# Switches headset to output-only profile, mutes mic, ensures output is unmuted at 30%

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

setup_music_audio() {
    local card_id=$(find_headset_card)
    if [[ -z "$card_id" ]]; then
        dunstify "Audio Music" "No compatible headset found - connect Avantree or Jabra first" --icon=audio-headphones --urgency=critical
        return 1
    fi

    # Switch to output-only profile
    pactl set-card-profile "$card_id" output:analog-stereo
    sleep 1

    # Mute microphone
    local default_source=$(pactl get-default-source)
    pactl set-source-mute "$default_source" 1

    # Unmute default sink and ensure minimum 30% volume
    local default_sink=$(pactl get-default-sink)
    pactl set-sink-mute "$default_sink" 0
    local current_vol=$(pactl get-sink-volume "$default_sink" | grep -oP '\d+%' | head -1 | tr -d '%')
    if [[ "$current_vol" -lt 30 ]]; then
        pactl set-sink-volume "$default_sink" 30%
    fi

    dunstify "Audio Music" "Music mode activated - Mic: muted, Output: unmuted" --icon=audio-headphones
    return 0
}

# Execute setup
setup_music_audio
