-- Bluetooth configuration for Bose QuietComfort headphones
-- 
-- This configuration enables two key improvements:
-- 1. mSBC codec: Upgrades microphone quality from 8kHz CVSD to 16kHz mSBC
--    Result: Much clearer voice quality in calls and voice chat
-- 2. Hardware volume sync: Links headphone volume controls to system volume
--    Result: Volume buttons on headphones directly control system volume
--
bluez_monitor.properties = {
  ["bluez5.enable-msbc"] = true,     -- Enable high-quality microphone codec
  ["bluez5.enable-hw-volume"] = true, -- Enable volume synchronization
}