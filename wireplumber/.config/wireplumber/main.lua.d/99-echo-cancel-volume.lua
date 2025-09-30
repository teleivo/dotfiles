-- Only limit Avantree hardware volume, don't interfere with echo cancellation
table.insert(alsa_monitor.rules, {
  matches = {
    {
      { "node.name", "matches", "alsa_output.usb-Avantree*" },
    },
  },
  apply_properties = {
    ["node.volume.max"] = 0.4,  -- Limit to 40% max
    ["node.volume"] = 0.25,     -- Default to 25%
  },
})