-- Audio Device Priority Configuration
-- Primary: Avantree C81 (highest priority when available)
-- Fallback: Jabra Link 380 (medium priority)
-- Last resort: Built-in audio (lowest priority ~1000)

-- Rule for Avantree output (sink) - HIGHEST priority
avantree_sink_rule = {
  matches = {
    {
      { "node.name", "matches", "alsa_output.usb-Avantree_Avantree_C81_PC*analog-stereo*" },
    },
  },
  apply_properties = {
    ["priority.driver"] = 2000,    -- HIGHEST priority - always preferred when available
    ["priority.session"] = 2000,
    ["node.description"] = "Avantree C81(PC) Audio Output (Primary)",
  },
}

-- Rule for Avantree input (source) - HIGHEST priority
avantree_source_rule = {
  matches = {
    {
      { "node.name", "matches", "alsa_input.usb-Avantree_Avantree_C81_PC*mono-fallback*" },
    },
  },
  apply_properties = {
    ["priority.driver"] = 2000,    -- HIGHEST priority for dictation
    ["priority.session"] = 2000,
    ["node.description"] = "Avantree C81(PC) Microphone (Primary)",
  },
}

-- Rule for Jabra output (sink) - FALLBACK priority
jabra_sink_rule = {
  matches = {
    {
      { "node.name", "matches", "alsa_output.usb-0b0e_Jabra_Link_380*analog-stereo*" },
    },
  },
  apply_properties = {
    ["priority.driver"] = 1500,    -- Medium priority - fallback when Avantree unavailable
    ["priority.session"] = 1500,
    ["node.description"] = "Jabra Link 380 Audio Output (Fallback)",
  },
}

-- Rule for Jabra input (source) - FALLBACK priority
jabra_source_rule = {
  matches = {
    {
      { "node.name", "matches", "alsa_input.usb-0b0e_Jabra_Link_380*mono-fallback*" },
    },
  },
  apply_properties = {
    ["priority.driver"] = 1500,    -- Medium priority fallback for microphone
    ["priority.session"] = 1500,
    ["node.description"] = "Jabra Link 380 Microphone (Fallback)",
  },
}

-- Apply the rules
table.insert(alsa_monitor.rules, avantree_sink_rule)
table.insert(alsa_monitor.rules, avantree_source_rule)
table.insert(alsa_monitor.rules, jabra_sink_rule)
table.insert(alsa_monitor.rules, jabra_source_rule)

-- Additional rule to force default selection behavior
default_selection_rule = {
  matches = {
    {
      { "node.name", "matches", "alsa_output.usb-Avantree_Avantree_C81_PC*analog-stereo*" },
    },
  },
  apply_properties = {
    ["priority.driver"] = 2000,
    ["priority.session"] = 2000,
    ["node.description"] = "Avantree C81(PC) Audio Output (Priority Override)",
    ["device.intended-roles"] = "Multimedia",
  },
}

table.insert(alsa_monitor.rules, default_selection_rule)