-- Automatic linking for Avantree WebRTC Echo Cancellation
-- Links raw Avantree microphone to WebRTC processing input when both nodes are available
--
-- This script monitors for:
-- 1. avantree_echo_cancel_capture (WebRTC processing input sink)
-- 2. alsa_input.usb-Avantree_Avantree_C81_PC*mono-fallback (raw microphone source)
--
-- When both are detected, it automatically creates a link between them
-- to enable WebRTC noise suppression, AGC, and echo cancellation

local lm = require("linking-manager")

Log.info("Loading Avantree WebRTC echo cancel linking script")

-- Monitor for both echo cancel capture sink and raw Avantree source
local om = ObjectManager({
  Interest({
    type = "node",
    Constraint({ "node.name", "matches", "avantree_echo_cancel_capture" }),
  }),
  Interest({
    type = "node",
    Constraint({ "node.name", "matches", "alsa_input.usb-Avantree_Avantree_C81_PC.*mono-fallback" }),
  }),
})

-- Track existing links to avoid duplicates
local existing_links = {}

-- Function to create link between raw source and WebRTC processing
local function create_avantree_webrtc_link()
  local capture_node = nil
  local source_node = nil

  -- Find both required nodes
  for node in om:iterate() do
    local node_name = node.properties["node.name"]
    if node_name and node_name:find("avantree_echo_cancel_capture") then
      capture_node = node
    elseif node_name and node_name:find("alsa_input.usb%-Avantree_Avantree_C81_PC.*mono%-fallback") then
      source_node = node
    end
  end

  -- Create link if both nodes exist and no link exists yet
  if capture_node and source_node then
    local link_key = source_node.properties["object.serial"] .. "->" .. capture_node.properties["object.serial"]

    if not existing_links[link_key] then
      Log.info(string.format("Creating WebRTC link: %s -> %s",
        source_node.properties["node.name"],
        capture_node.properties["node.name"]))

      -- Create the link with appropriate properties
      local link = Link("link-factory", {
        ["link.output.node"] = source_node.properties["object.serial"],
        ["link.input.node"] = capture_node.properties["object.serial"],
        ["link.output.port"] = "monitor_FL",
        ["link.input.port"] = "playback_FL",
        ["link.passive"] = false,
        ["object.linger"] = true,
      })

      if link then
        link:activate(Feature.Proxy.BOUND)
        existing_links[link_key] = true
        Log.info("Avantree WebRTC link created successfully")
      else
        Log.warning("Failed to create Avantree WebRTC link")
      end
    end
  end
end

-- Handle node additions
om:connect("object-added", function(om, node)
  local node_name = node.properties["node.name"]
  if node_name and (node_name:find("avantree_echo_cancel_capture") or
                   node_name:find("alsa_input.usb%-Avantree_Avantree_C81_PC.*mono%-fallback")) then
    Log.info("Avantree audio node detected: " .. node_name)
    -- Delay slightly to ensure both nodes are fully ready
    Core.timeout_add(1000, function()
      create_avantree_webrtc_link()
      return false -- Don't repeat
    end)
  end
end)

-- Handle node removals (cleanup tracking)
om:connect("object-removed", function(om, node)
  local node_name = node.properties["node.name"]
  if node_name and (node_name:find("avantree_echo_cancel_capture") or
                   node_name:find("alsa_input.usb%-Avantree_Avantree_C81_PC.*mono%-fallback")) then
    Log.info("Avantree audio node removed: " .. node_name)
    -- Clear existing links tracking when nodes are removed
    existing_links = {}
  end
end)

-- Activate the object manager
om:activate()

Log.info("Avantree WebRTC echo cancel linking script loaded")