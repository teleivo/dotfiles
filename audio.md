# Audio Setup

**PipeWire** moves audio between applications and hardware devices, while **WirePlumber** decides which devices should be the defaults based on my priority rules.

## Audio Flow Diagram

```
Hardware Devices
├── Avantree C81 (USB) ────── Priority 2000 ──┐
├── Jabra (USB) ────────────── Priority 1500 ──┼─── WirePlumber ──── Default Selection
└── Built-in Audio ─────────── Priority 1000 ──┘         │
                                                          │
Profile Scripts                                           │
├── audio-calls ──── duplex profile ─────────────────────┐│
├── audio-music ──── output-only profile ────────────────┤│
└── dictation-toggle ──── duplex + state management ─────┘│
                                                           │
Applications ────────────────────── @DEFAULT_SINK@ ←──────┘
├── Chrome                         @DEFAULT_SOURCE@
├── Rhythmbox
└── Other apps
```

## Configuration Overview

### Priority System (WirePlumber Lua)
**File**: `wireplumber/main.lua.d/60-avantree-priority.lua`
- **Avantree enhanced**: Priority 3100 (WebRTC-processed microphone, highest)
- **Avantree raw**: Priority 3000 (direct from USB device)
- **Jabra**: Priority 2500 (fallback when Avantree unavailable)
- **Built-in**: Priority ~2009 (system default, last resort)

**File**: `wireplumber/main.lua.d/70-avantree-echo-cancel-priority.lua`
- **Enhanced source priority**: Ensures WebRTC-processed source becomes default
- **Communication role**: Marks enhanced source for call applications

### WebRTC Audio Processing
**File**: `pipewire/.config/pipewire/pipewire.conf.d/99-avantree-call-enhancement.conf`
- **Purpose**: Creates WebRTC echo-cancel module with noise suppression, AGC, echo cancellation
- **Creates**: `avantree_echo_cancel_source` (enhanced microphone output)
- **Status**: Currently not auto-connecting to raw microphone input

**File**: `wireplumber/.config/wireplumber/wireplumber.conf.d/99-avantree-webrtc-autoconnect.conf`
- **Purpose**: Attempt to auto-connect raw microphone to WebRTC processing
- **Status**: Not currently working - needs manual connection

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

### Current Setup (As of 2024-09)

1. **WirePlumber Priority System**
   - Detects USB audio devices and assigns priorities via `60-avantree-priority.lua`
   - **Avantree enhanced**: 3100 priority (highest - WebRTC processed microphone)
   - **Avantree raw**: 3000 priority (raw microphone from device)
   - **Jabra**: 2500 priority (fallback when Avantree unavailable)
   - **Built-in**: ~2009 priority (last resort)

2. **WebRTC Processing Chain**
   - `99-avantree-call-enhancement.conf` creates enhanced microphone with noise suppression
   - Enhanced source (`avantree_echo_cancel_source`) becomes default automatically
   - **Currently**: Raw microphone connection to WebRTC processing needs manual setup
   - **Result**: Enhanced microphone is default but may not have active audio processing

3. **Profile Management**
   - `audio call` - Switch to duplex mode (mic enabled)
   - `audio music` - Switch to output-only mode (mic muted)
   - `audio test out` - Test speakers/headphones with speaker-test
   - `audio test loopback` - Test microphone quality (currently uses raw mic as fallback)

4. **Automatic Device Selection**
   - Applications use `@DEFAULT_SINK@`/`@DEFAULT_SOURCE@` automatically
   - Highest priority available device becomes default
   - No manual routing needed for device switching

## Troubleshooting

### Audio Coming from Wrong Device

**Check priority system:**
```sh
wpctl status  # Look for * next to correct device
pactl list sinks | grep -A 2 "priority.driver"  # Should show 2000 for Avantree
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

### Dictation Doesn't Restore State

**Check debug log:**
```sh
tail -20 /run/user/$UID/dictation/debug.log
```

**Check if state file exists during dictation:**
```sh
ls -la /run/user/$UID/dictation/audio_state
```

## Validation Commands

```sh
# Test priority system
pactl get-default-sink  # Should be Avantree when connected

# Test profile switching
audio music && sleep 2 && audio call

# Test suspension prevention
pactl list sinks short | grep Avantree  # Should show RUNNING

# Verify no stored conflicts
wpctl status | grep "Default Configured"  # Should be empty or match current devices

# Test audio output and loopback
audio test out      # Test speakers/headphones
audio test loopback # Test microphone quality
```

## WebRTC Processing Status - RESOLVED ✅

### Current Status (Updated 2025-09-26)
- ✅ **Priority system working** - Avantree sources get highest priority (3000-3100)
- ✅ **Audio routing fixed** - No more suspended/conflicting devices
- ✅ **Hardware detection working** - Avantree device properly detected and prioritized
- ✅ **Manual switching working** - `audio call`/`audio music` profile switching functional
- ✅ **Auto-switching enabled** - USB device auto-switches to duplex mode on connection
- ✅ **Basic audio fully working** - Both `audio test out` and `audio test loopback` functional
- ✅ **WebRTC infrastructure working** - Enhanced source created and set as default
- ✅ **AUTOMATIC WEBRTC CONNECTION WORKING** - Enhanced microphone automatically processes raw input

### Solution Implemented
**Systemd User Service Approach**: Created `avantree-webrtc-link.service` that automatically connects the raw Avantree microphone to the WebRTC processing chain when both nodes are available.

**Components:**
- **Script**: `bin/bin/avantree-webrtc-connect` - Waits for nodes and creates connection
- **Service**: `systemd/.config/systemd/user/avantree-webrtc-link.service` - Runs automatically with PipeWire
- **Method**: Uses `module-loopback` to link raw microphone → WebRTC processing → enhanced output

### How It Works Now
1. **PipeWire starts** and loads WebRTC echo-cancel module
2. **Enhanced source** (`avantree_echo_cancel_source`) becomes default (priority 3100)
3. **Auto-link service** detects both raw mic and WebRTC nodes
4. **Automatic connection** created via module-loopback
5. **WebRTC processing active** - noise suppression, AGC, echo cancellation working
6. **Applications use enhanced source** automatically via `@DEFAULT_SOURCE@`

### Current Behavior
- ✅ **`audio test loopback`** shows: "Using enhanced microphone with WebRTC processing"
- ✅ **Call applications** get processed audio with noise suppression and AGC
- ✅ **No manual setup required** - works automatically on device connection
- ✅ **Service restarts with PipeWire** - persistent across reboots

### Files Modified
- **Enhanced**: `pipewire/.config/pipewire/pipewire.conf.d/99-avantree-call-enhancement.conf` - WebRTC module config
- **Fixed**: `bin/bin/audio` - Removed fallback logic that bypassed WebRTC processing
- **New**: `bin/bin/avantree-webrtc-connect` - Auto-connection script
- **New**: `systemd/.config/systemd/user/avantree-webrtc-link.service` - Auto-start service