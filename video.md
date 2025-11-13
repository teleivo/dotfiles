# Video Setup

**OBS Studio** captures screen via PipeWire and records/streams video. The canvas resolution must
match your display to avoid cropping/scaling issues.

## Display Configuration

```
Hardware
├── External (DP-2): 3840x2160 @ 30Hz with 1.5x scale = 2560x1440 effective
└── Laptop (eDP-1):  3840x2400 @ 60Hz (disabled when external connected)

OBS Profiles
├── External ──── 2560x1440 @ 30fps ──── matches scaled external display
└── Laptop ────── 3840x2400 @ 30fps ──── matches native laptop display
```

## Configuration Overview

### OBS Profiles

**Files**: `obs/.config/obs-studio/basic/profiles/{External,Laptop}/basic.ini`

* **External profile**: 2560x1440 canvas matches Dell monitor with 1.5x scaling
* **Laptop profile**: 3840x2400 canvas matches laptop's native resolution
* **Manual switching**: Profile menu in OBS when changing displays

### Virtual Camera

**File**: `ansible/playbooks/roles/base/tasks/obs.yml`

* **v4l2loopback module**: Creates `/dev/video10` for virtual camera
* **Usage**: OBS → Tools → Start Virtual Camera → appears in browser/Zoom/Slack

## How It Works

1. **PipeWire Screen Capture**
   * OBS uses `pipewire-desktop-capture-source` to capture screen
   * Capture resolution matches display's actual output (native or scaled)
   * No automatic scaling applied by PipeWire

2. **Canvas Sizing Problem**
   * OBS canvas acts as a fixed-size frame for all sources
   * If canvas is smaller than capture source, only portion of screen appears
   * Must manually match canvas to display resolution

3. **Profile Switching**
   * External monitor: Switch to "External" profile (2560x1440)
   * Laptop screen: Switch to "Laptop" profile (3840x2400)
   * No automatic detection - manual selection required

## Troubleshooting

### Screen Sharing Not Working in Chrome/Meet

**Symptom**: Screen picker dialog doesn't appear or screen sharing fails in Chrome/Google Meet

**Check for portal errors:**
```sh
systemctl --user status xdg-desktop-portal | tail -20
```

Look for PipeWire connection errors like:
* `Caught PipeWire error: connection error`
* `PipeWire roundtrip timed out waiting for events`
* `Failed connect to PipeWire: No node factory discovered`

**Fix:**
```sh
systemctl --user restart xdg-desktop-portal-wlr xdg-desktop-portal
```

Then restart Chrome completely and try screen sharing again.

**Cause**: The portal service can lose its PipeWire connection when PipeWire/WirePlumber restarts
or during session startup race conditions.

## Validation Commands

```sh
# Check current display resolution and scaling
swaymsg -t get_outputs

# Verify OBS profiles exist
ls ~/.config/obs-studio/basic/profiles/

# Test virtual camera device
ls -l /dev/video10
v4l2-ctl --device=/dev/video10 --all

# Verify v4l2loopback module loaded
lsmod | grep v4l2loopback

# Check portal status
systemctl --user status xdg-desktop-portal xdg-desktop-portal-wlr
```
