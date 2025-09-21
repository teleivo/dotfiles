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
**File**: `pipewire/.config/wireplumber/main.lua.d/60-avantree-priority.lua`
- **Avantree**: Priority 2000 (always preferred when available)
- **Jabra**: Priority 1500 (fallback when Avantree unavailable)
- **Built-in**: Priority ~1000 (last resort)

### Suspension Prevention
**File**: `wireplumber/.config/wireplumber/wireplumber.conf.d/99-disable-headset-suspension.conf`
- **Purpose**: Prevents USB headsets from suspending during profile changes
- **Effect**: Keeps audio devices active and immediately available

### Target Storage Disable
**File**: `wireplumber/.config/wireplumber/wireplumber.conf.d/99-disable-default-target-storage.conf`
- **Purpose**: Forces priority-based selection instead of remembering specific devices
- **Effect**: WirePlumber always selects highest priority available device

### Profile Management Scripts
**Location**: `bin/bin/audio-*`
- **audio-calls**: Switch to duplex mode (mic enabled)
- **audio-music**: Switch to output-only mode (mic disabled)
- **dictation-toggle**: Full state preservation and restoration

### Common Utilities
**File**: `bin/bin/audio-utils`
- **get_headset_card_id()**: Finds card ID from WirePlumber's default device
- **is_headset_active()**: Checks if current default is a headset

## How It Works

1. **WirePlumber** detects USB audio devices and assigns priorities
2. **Highest priority device** automatically becomes default sink/source
3. **Profile scripts** switch between output-only and duplex modes
4. **Applications** use `@DEFAULT_SINK@`/`@DEFAULT_SOURCE@` automatically
5. **No manual routing** needed - everything follows priority system

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
audio-music && sleep 2 && audio-calls

# Test suspension prevention
pactl list sinks short | grep Avantree  # Should show RUNNING

# Verify no stored conflicts
wpctl status | grep "Default Configured"  # Should be empty or match current devices
```