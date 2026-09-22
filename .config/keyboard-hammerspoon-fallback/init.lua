-- ~/.hammerspoon/init.lua
--
-- Karabiner-Elements replacement for Macs that cannot install third-party
-- driver extensions (OSSystemExtensionErrorDomain error 10,
-- forbiddenBySystemPolicy). Uses only the Accessibility API, so it needs no
-- system or driver extension of its own.
--
-- Replicates three rules from ~/.config/karabiner/karabiner.json:
--   1. Caps Lock held with another key   -> Control
--      Caps Lock tapped alone            -> Escape
--   2. Left Shift + Right Shift together -> toggle Caps Lock
--   3. Control + [                       -> Escape
--
-- Caps Lock is remapped to Right Control by hidutil, loaded at login from
-- ~/Library/LaunchAgents/local.hidutil.capslock.plist. Everything here keys
-- off Right Control, so the physical Left Control key keeps its ordinary
-- behaviour. The Karabiner rule made both keys dual-role; this does not.

local log = hs.logger.new("keys", "info")

-- Device-dependent modifier bits, from IOKit hidsystem/IOLLEvent.h.
local LCTRL  = 0x00000001 -- NX_DEVICELCTLKEYMASK
local LSHIFT = 0x00000002 -- NX_DEVICELSHIFTKEYMASK
local RSHIFT = 0x00000004 -- NX_DEVICERSHIFTKEYMASK
local LCMD   = 0x00000008 -- NX_DEVICELCMDKEYMASK
local RCMD   = 0x00000010 -- NX_DEVICERCMDKEYMASK
local LALT   = 0x00000020 -- NX_DEVICELALTKEYMASK
local RALT   = 0x00000040 -- NX_DEVICERALTKEYMASK
local RCTRL  = 0x00002000 -- NX_DEVICERCTLKEYMASK

-- Anything that turns a Caps Lock press into a Control press.
local OTHER_MODS = LCTRL | LSHIFT | RSHIFT | LCMD | RCMD | LALT | RALT

-- Karabiner's to_if_alone default: a longer press is a plain hold, not a tap.
local TAP_TIMEOUT = 1.0

local function isSet(flags, bit)
  return (flags & bit) ~= 0
end

-- rawFlags() is the documented accessor; fall back for older Hammerspoon.
local function rawFlags(e)
  if e.rawFlags then
    return e:rawFlags()
  end
  return e:getRawEventData().CGEventData.flags
end

-- Escape with its flags explicitly cleared. Caps Lock is still physically
-- down when this fires, so without the clear an app would see Ctrl+Escape.
local function escapeEvents()
  local down = hs.eventtap.event.newKeyEvent({}, "escape", true)
  local up = hs.eventtap.event.newKeyEvent({}, "escape", false)
  down:setFlags({})
  up:setFlags({})
  return { down, up }
end

local function postEscape()
  for _, e in ipairs(escapeEvents()) do
    e:post()
  end
end

local function toggleCapsLock()
  local caps = hs.hid and hs.hid.capslock
  if not caps then
    log.e("hs.hid.capslock unavailable; cannot toggle Caps Lock")
    return
  end
  caps.set(not caps.get())
end

----------------------------------------------------------------------
-- State shared between the two taps
----------------------------------------------------------------------
local capsDown = false      -- Caps Lock (now Right Control) is held
local capsPressedAt = 0
local capsUsedAsMod = false -- something else happened while it was held
local shiftsLatched = false -- both shifts seen; wait for a release

----------------------------------------------------------------------
-- Tap 1: modifier changes
----------------------------------------------------------------------
local function onFlagsChanged(e)
  local flags = rawFlags(e)
  local caps = isSet(flags, RCTRL)

  if caps and not capsDown then
    capsDown = true
    capsPressedAt = hs.timer.secondsSinceEpoch()
    capsUsedAsMod = false
  elseif not caps and capsDown then
    capsDown = false
    local held = hs.timer.secondsSinceEpoch() - capsPressedAt
    if not capsUsedAsMod and held < TAP_TIMEOUT then
      postEscape()
    end
  end

  -- Caps Lock combined with another modifier is a Control press, not a tap.
  if capsDown and isSet(flags, OTHER_MODS) then
    capsUsedAsMod = true
  end

  -- Rule 2: both shifts down together toggles Caps Lock exactly once.
  if isSet(flags, LSHIFT) and isSet(flags, RSHIFT) then
    if not shiftsLatched then
      shiftsLatched = true
      toggleCapsLock()
    end
  else
    shiftsLatched = false
  end

  return false
end

----------------------------------------------------------------------
-- Tap 2: key and mouse presses
----------------------------------------------------------------------
local OPEN_BRACKET = hs.keycodes.map["["]

local function onKeyOrClick(e)
  -- Any real press while Caps Lock is held means it acted as Control.
  capsUsedAsMod = capsUsedAsMod or capsDown

  -- Rule 3: Control + [ becomes Escape, with any other modifiers allowed,
  -- matching the "optional: any" in the Karabiner rule.
  if e:getType() == hs.eventtap.event.types.keyDown
     and e:getKeyCode() == OPEN_BRACKET
     and e:getFlags().ctrl then
    return true, escapeEvents()
  end

  return false
end

----------------------------------------------------------------------
-- Start. Globals, so the taps are not garbage collected.
----------------------------------------------------------------------
local types = hs.eventtap.event.types

flagsTap = hs.eventtap.new({ types.flagsChanged }, onFlagsChanged)
flagsTap:start()

keyTap = hs.eventtap.new({
  types.keyDown,
  types.leftMouseDown,
  types.rightMouseDown,
  types.otherMouseDown,
}, onKeyOrClick)
keyTap:start()

configWatcher = hs.pathwatcher.new(hs.configdir, function(files)
  for _, f in ipairs(files) do
    if f:sub(-4) == ".lua" then
      hs.reload()
      return
    end
  end
end)
configWatcher:start()

log.i("keyboard rules loaded")
