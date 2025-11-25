# Audio Setup

**PipeWire** moves audio between applications and hardware devices, while **WirePlumber** decides which devices should be the defaults based on my priority rules.

## Audio Flow Diagram

```
Hardware Devices
├── Jabra (USB) ────────────── Priority 3000 ──┐
├── Avantree C81 (USB) ────── Priority 2500 ──┼─── WirePlumber ──── Default Selection
└── Built-in Audio ─────────── Priority ~2000 ─┘         │
                                                          │
Profile Scripts                                           │
├── audio call ──── duplex profile ──────────────────────┐│
├── audio music ──── output-only profile ────────────────┤│
└── dictation-toggle ──── duplex + state management ─────┘│
                                                           │
Applications ────────────────────── @DEFAULT_SINK@ ←──────┘
├── Chrome                         @DEFAULT_SOURCE@
├── Rhythmbox
└── Other apps
```

## Configuration Overview

### Priority System (WirePlumber)
**File**: `wireplumber/wireplumber.conf.d/60-device-priority.conf`
- **Jabra**: Priority 3000 (highest - primary device when available)
- **Avantree**: Priority 2500 (fallback when Jabra unavailable)
- **Built-in**: Priority ~2000 (system default, last resort)

### Device Management
**File**: `wireplumber/.config/wireplumber/wireplumber.conf.d/99-disable-headset-suspension.conf`
- **Purpose**: Prevents USB headsets from suspending during profile changes
- **Effect**: Keeps audio devices active and immediately available

**File**: `wireplumber/.config/wireplumber/wireplumber.conf.d/99-disable-default-target-storage.conf`
- **Purpose**: Forces priority-based selection instead of remembering specific devices
- **Effect**: WirePlumber always selects highest priority available device

### Audio Control Scripts
**File**: `bin/bin/audio` (unified script)
- **audio call**: Switch to duplex mode (mic enabled)
- **audio music**: Switch to output-only mode (mic muted)
- **audio test out**: Test speakers/headphones with speaker-test
- **audio test loopback**: Test microphone quality with real-time monitoring
- **audio info**: Show current audio system status

**File**: `bin/bin/audio-utils`
- **get_headset_card_id()**: Finds card ID from WirePlumber's default device
- **is_headset_active()**: Checks if current default is a headset

## How It Works

### Current Setup

1. **WirePlumber Priority System**
   - Detects USB audio devices and assigns priorities via `60-device-priority.conf`
   - **Jabra**: 3000 priority (highest - primary device)
   - **Avantree**: 2500 priority (fallback when Jabra unavailable)
   - **Built-in**: ~2000 priority (last resort)

2. **Profile Management**
   - `audio call` - Switch to duplex mode (mic enabled)
   - `audio music` - Switch to output-only mode (mic muted)
   - `audio test out` - Test speakers/headphones with speaker-test
   - `audio test loopback` - Test microphone quality

3. **Automatic Device Selection**
   - Applications use `@DEFAULT_SINK@`/`@DEFAULT_SOURCE@` automatically
   - Highest priority available device becomes default
   - No manual routing needed for device switching
   - Conferencing apps (Chrome, Teams, Zoom) handle their own audio processing

## Troubleshooting

### Audio Coming from Wrong Device

**Check priority system:**
```sh
wpctl status  # Look for * next to correct device
pactl list sinks | grep -A 2 "priority.driver"  # Should show 3000 for Jabra, 2500 for Avantree
```

**Fix:**
```sh
systemctl --user restart wireplumber
```

### Scripts Don't Switch Profiles

**Check if headset detected:**
```sh
source bin/bin/audio-utils
get_headset_card_id  # Should return card number
```

**Check available profiles:**
```sh
pactl list cards | grep -A 20 "Avantree" | grep "Profile"
```

### Profile Changes Break Audio Routing

**Check for suspension:**
```sh
pactl list sinks short | grep -E "(Avantree|Jabra)"  # Should show RUNNING not SUSPENDED
```

**Check stored defaults conflict:**
```sh
wpctl status | tail -5  # Should show no conflicting stored devices
```

**Nuclear option:**
```sh
rm ~/.local/state/wireplumber/default-nodes
systemctl --user restart wireplumber
```


## Validation Commands

```sh
# Test priority system
pactl get-default-sink  # Should be Jabra when connected, Avantree when Jabra unavailable

# Test profile switching
audio music && sleep 2 && audio call

# Test suspension prevention
pactl list sinks short | grep -E "(Jabra|Avantree)"  # Should show RUNNING

# Verify no stored conflicts
wpctl status | grep "Default Configured"  # Should be empty or match current devices

# Test audio output and loopback
audio test out      # Test speakers/headphones
audio test loopback # Test microphone quality
```

