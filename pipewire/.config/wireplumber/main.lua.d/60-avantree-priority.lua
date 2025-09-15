-- Set Avantree C81 as high priority default audio devices
-- This ensures it's automatically selected when available

-- Rule for Avantree output (sink) - higher priority for music
avantree_sink_rule = {
  matches = {
    {
      { "node.name", "matches", "alsa_output.usb-Avantree_Avantree_C81_PC*analog-stereo*" },
    },
  },
  apply_properties = {
    ["priority.driver"] = 1200,    -- Higher than built-in (1000) but lower than 1500
    ["priority.session"] = 1200,
    ["node.description"] = "Avantree C81(PC) Audio Output",
  },
}

-- Rule for Avantree input (source) - higher priority for dictation
avantree_source_rule = {
  matches = {
    {
      { "node.name", "matches", "alsa_input.usb-Avantree_Avantree_C81_PC*mono-fallback*" },
    },
  },
  apply_properties = {
    ["priority.driver"] = 1800,    -- Higher than built-in (~1600)
    ["priority.session"] = 1800,
    ["node.description"] = "Avantree C81(PC) Microphone",
  },
}

-- Apply the rules
table.insert(alsa_monitor.rules, avantree_sink_rule)
table.insert(alsa_monitor.rules, avantree_source_rule)