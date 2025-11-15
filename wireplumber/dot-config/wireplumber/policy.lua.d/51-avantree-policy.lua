-- Enable automatic profile switching for USB audio devices
-- This works alongside manual switching via the 'audio' script
-- Auto-switches to duplex when device connects, manual control still available

audio_policy = {
  -- Auto-switch to headset profile when USB audio device connects
  ["audio.autoswitch-to-headset-profile"] = true,
  ["audio.rate"] = 48000,
  ["api.alsa.headroom"] = 0,
}

-- Keep Bluetooth enabled but don't auto-switch to it
-- WirePlumber priority system will handle device selection
bluetooth_policy.policy = {
  ["bluetooth.autoswitch-to-headset-profile"] = false,  -- Don't auto-switch to BT
  ["bluetooth.disable"] = false  -- Keep Bluetooth available for other devices
}