# Notification

This system uses **mako** as the notification daemon with click-to-focus and do-not-disturb
functionality for Sway/Wayland.

## Architecture

### Components

* **Mako** - Notification daemon (Wayland-native, from emersion/Sway ecosystem)
* **notify-focus** - Custom script that focuses windows when notifications are clicked
* **notify-toggle** - Custom script that toggles do-not-disturb mode
* **libnotify-bin** - Provides command-line notification tools

## Flow Diagrams

### Native Application Notifications (Chrome, Ghostty, ...)

```
Native App (e.g., Chrome)
  ↓ (uses libnotify library)
D-Bus: org.freedesktop.Notifications
  ↓
Mako (listening on D-Bus)
  ↓ (displays with Dogrun theme)
Notification appears
  ↓ (user clicks)
Mako executes: ~/.local/bin/notify-focus "$id"
  ↓
Script queries: makoctl list (gets app-name)
  ↓
Script executes: swaymsg focus (with fallback strategies)
  ↓
Window focused + Notification dismissed
✓ Click-to-focus working!
```

### Screenshot Script Notifications

```
screenshot script (called from snap terminal)
  ↓
notify-send with env -i (clean environment)
  ↓ (removes snap confinement detection)
D-Bus: org.freedesktop.Notifications
  ↓
Mako (listening on D-Bus)
  ↓
Notification with Dogrun theme
  ↓ (click works)
Window focused + Dismissed
✓ Full functionality
```

## Configuration

### Mako Config Location

`mako/.config/mako/config`

Key settings:

* **Geometry**: `width=300 height=300 anchor=top-right margin=50`
* **Theme**: Dogrun colors (#222433 background, #b871b8 border, #9ea3c0 text)
* **Click action**: `on-button-left=exec ~/.local/bin/notify-focus "$id"`
* **Do Not Disturb mode**: `[mode=do-not-disturb]` with `invisible=1` hides all notifications

### Scripts

#### Focus Script

`bin/.local/bin/notify-focus`

How it works:

1. Receives notification ID from mako
2. Queries mako: `makoctl list` to get `app-name`
3. Tries multiple strategies to focus window:
   * Exact app_id match
   * Remove .desktop suffix
   * Case-insensitive match
   * Fuzzy match (contains)
   * Common variations (lowercase, uppercase)
   * WM_CLASS for X11 apps
4. Dismisses notification: `makoctl dismiss -n "$id"`

#### Do Not Disturb Toggle

`bin/.local/bin/notify-toggle`

How it works:

1. **Status mode**: Checks if `do-not-disturb` mode is active, outputs JSON for Waybar
2. **Toggle mode**: Adds or removes `do-not-disturb` mode using `makoctl mode -a/-r`
3. Signals Waybar to refresh the DND indicator

**Usage**:

* **Keyboard**: `$mod+n` toggles DND mode
* **Waybar**: Click the bell icon (󰂜/󰂛) to toggle
* **Visual**: Bell-slash icon (󰂛) and red background when DND is active

## Snap Terminal Environment Issue (SOLVED)

### The Problem

When running commands from snap-packaged terminals (like Ghostty), libnotify detects the snap
environment variables and assumes the process is sandboxed. This causes it to route notifications
through the XDG Desktop Portal instead of directly to mako, resulting in:

* Portal uses GTK's built-in notification UI
* Portal completely ignores mako configuration
* Notifications appear with GTK theme instead of Dogrun colors
* Click-to-focus functionality unavailable

### The Solution

Use `env -i` to run `notify-send` with a clean environment, keeping only the essential variables
needed for D-Bus communication. This prevents libnotify from detecting confinement and ensures
notifications go directly to mako.

**Implementation** (see `bin/.local/bin/screenshot`):

```bash
notify_clean() {
  local urgency="${1}"
  local summary="${2}"
  local body="${3}"

  env -i \
    HOME="$HOME" \
    DBUS_SESSION_BUS_ADDRESS="$DBUS_SESSION_BUS_ADDRESS" \
    DISPLAY="$DISPLAY" \
    WAYLAND_DISPLAY="$WAYLAND_DISPLAY" \
    XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" \
    notify-send --urgency="$urgency" "$summary" "$body"
}
```

**Result**: All notifications now use Dogrun theme with full click-to-focus functionality ✓

### Why This Works for Any Snap App

This approach is universal and works for any script or application that needs to send
notifications from within a snap environment. The key insight is that libnotify's confinement
detection is environment-based, so providing a clean environment bypasses the portal entirely.

## Do Not Disturb (Focus Mode)

The system includes a do-not-disturb mode that hides all notifications during focus sessions.

### Features

* **Keyboard shortcut**: `$mod+n` - Quick toggle from anywhere
* **Waybar button**: Visual indicator in status bar
  * Bell icon (󰂜) - Notifications enabled
  * Bell-slash icon (󰂛) with red background - DND active
* **Mako mode system**: Uses mako's built-in mode feature
* **Non-persistent**: DND resets on reboot (expected behavior)

### How It Works

When DND is enabled:

1. Mako activates `do-not-disturb` mode
2. All notifications are hidden (not dismissed, just invisible)
3. Waybar icon changes to show active DND state
4. Notifications are queued and will appear when DND is disabled

### Integration with System

* **Screen lock**: Automatically enables DND during lock (`$mod+Ctrl+l`)
* **Idle timeout**: DND activates before automatic screen lock
* **Waybar**: Custom module shows current state with tooltip

## Installation

### Ansible

```bash
cd ansible && ansible-playbook playbooks/home.yml --tags "mako,stow"
```

This:

* Installs mako-notifier and libnotify-bin packages
* Creates symlinks for mako config, notify-focus, and notify-toggle scripts

### Manual Verification

```bash
# Check mako is running
ps aux | grep mako

# Test notification with libnotify
notify-send "Test" "Click to focus!"

# Test DND toggle
~/.local/bin/notify-toggle toggle
makoctl mode  # Should show "do-not-disturb"

# Test again to disable
~/.local/bin/notify-toggle toggle
makoctl mode  # Should show "default"

# Test keyboard shortcut
# Press $mod+n to toggle DND
```

## Troubleshooting

### Notifications not appearing

Check mako is running:

```bash
ps aux | grep mako
```

Check mako config is loaded:

```bash
makoctl reload
```

### Notifications appear but clicking does nothing

Check notify-focus script exists and is executable:

```bash
ls -la ~/.local/bin/notify-focus
```

Test script manually:

```bash
# Get a notification ID
makoctl list

# Test focus (replace 123 with actual ID)
~/.local/bin/notify-focus 123
```

### DND not toggling

Check notify-toggle script exists and is executable:

```bash
ls -la ~/.local/bin/notify-toggle
```

Test manually:

```bash
# Test toggle
~/.local/bin/notify-toggle toggle

# Check status output
~/.local/bin/notify-toggle status

# Check mako mode
makoctl mode
```

### Waybar DND icon not updating

Verify Waybar configuration includes the custom DND module and signal is working:

```bash
# Manually trigger Waybar refresh
pkill -RTMIN+11 waybar
```

## References

* [Mako GitHub](https://github.com/emersion/mako)
* [Mako Man Page](https://man.archlinux.org/man/mako.5)
* [D-Bus Notification Spec](https://specifications.freedesktop.org/notification-spec/latest/)
* [Sway Window Criteria](https://man.archlinux.org/man/sway.5#CRITERIA)
