-- Set Avantree C81 as preferred default devices
-- Ensures dictation and audio routing work consistently

default_policy.policy = {
  -- Prefer Avantree devices for audio routing
  ["device.routes.default-sink-volume"] = 1.0,
  ["device.routes.default-source-volume"] = 1.0,
}