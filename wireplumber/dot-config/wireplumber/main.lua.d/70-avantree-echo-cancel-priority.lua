-- Avantree Echo Cancel Enhanced Source Priority
-- Ensures the WebRTC-processed source becomes default when Avantree is connected

avantree_echo_cancel_source_rule = {
  matches = {
    {
      { "node.name", "matches", "avantree_echo_cancel_source" },
    },
  },
  apply_properties = {
    ["priority.driver"] = 3100,    -- Higher than raw Avantree (3000)
    ["priority.session"] = 3100,
    ["node.description"] = "Avantree C81(PC) Microphone (Enhanced)",
    ["device.intended-roles"] = "Communication",
  },
}

table.insert(alsa_monitor.rules, avantree_echo_cancel_source_rule)