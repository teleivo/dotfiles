# Notification

This system uses **mako** as the notification daemon with click-to-focus and do-not-disturb
functionality for Sway/Wayland.

## How It Works

Apps/scripts → `notify-send`/D-Bus → Mako (Dogrun theme) → Click → `notify-focus` → Window focuses

## Configuration

* **Mako config**: `mako/.config/mako/config` - Dogrun theme, urgency levels, click actions
* **Focus script**: `bin/.local/bin/notify-focus` - Focuses window when notification clicked
* **DND toggle**: `bin/.local/bin/notify-toggle` - Toggles do-not-disturb mode (`$mod+n`)

## Notification Tool Selection

### Using notify-send

Scripts should use `notify-send` (from libnotify-bin) for sending notifications, which works
reliably with mako for consistent theming.

**Implementation** (see `bin/.local/bin/screenshot`):

```bash
# Success notifications - auto-dismiss after 2s (urgency=low)
notify-send --urgency=low "Screenshot" "Screenshot copied to clipboard"

# Error notifications - require manual dismissal (urgency=critical)
notify-send --urgency=critical "Screenshot" "Unable to take screenshot"
```

**Note**: When running from snap terminals, you may see warnings like "Running in confined mode,
using Portal notifications". These warnings can be ignored - notifications still reach mako
correctly with proper Dogrun styling and click-to-focus functionality.

## Do Not Disturb Mode

Toggle with `$mod+n` or Waybar bell icon. Hides all notifications until disabled. Automatically
activates during screen lock/idle. See `bin/.local/bin/notify-toggle` and
`mako/.config/mako/config` for implementation.

## Installation

```bash
cd ansible && ansible-playbook playbooks/home.yml --tags "mako,stow"
```

Test: `notify-send "Test" "Click to focus!"` and `~/.local/bin/notify-toggle toggle`

## Troubleshooting

* **Not appearing**: Check `ps aux | grep mako` and `makoctl reload`
* **Click doesn't focus**: Test `~/.local/bin/notify-focus <id>` with ID from `makoctl list`
* **DND not toggling**: Test `~/.local/bin/notify-toggle toggle` and check `makoctl mode`
* **Waybar icon stuck**: Run `pkill -RTMIN+11 waybar`

## References

* [Mako GitHub](https://github.com/emersion/mako)
* [Mako Man Page](https://man.archlinux.org/man/mako.5)
* [D-Bus Notification Spec](https://specifications.freedesktop.org/notification-spec/latest/)
* [Sway Window Criteria](https://man.archlinux.org/man/sway.5#CRITERIA)
