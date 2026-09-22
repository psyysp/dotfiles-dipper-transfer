# Keyboard rules without Karabiner

A Hammerspoon replacement for three Karabiner-Elements complex modifications,
for Macs that cannot install third-party driver extensions
(`OSSystemExtensionErrorDomain error 10`, `forbiddenBySystemPolicy`).

Uses only the Accessibility API. No system or driver extension is involved.

## Rules replicated

| Behavior | Source rule in `~/.config/karabiner/karabiner.json` |
| --- | --- |
| Caps Lock held with another key acts as Control | "Change caps_lock to control if pressed with other keys, to escape if pressed alone." |
| Caps Lock tapped alone sends Escape | same rule, `to_if_alone` |
| Left Shift + Right Shift toggles Caps Lock | "Toggle caps_lock by pressing left_shift then right_shift" |
| Control + `[` sends Escape | "Map ctrl + [ to escape" |

## Choose how Caps Lock becomes Control

Pick one. The `CAPS_IS` setting at the top of `init.lua` must match.

### Option A — System Settings (simplest, the default)

System Settings, Keyboard, Keyboard Shortcuts, Modifier Keys: set Caps Lock to
Control. Leave `CAPS_IS = "any"`. Nothing else to install.

Set it for the keyboard you actually type on. This mapping is per-keyboard, so a
setting applied to the internal keyboard does not reach an external one.

Trade-off: `"any"` matches the generic Control flag, so every Control-producing
key gains the tap-for-Escape behavior, including the physical Left and Right
Control keys. A Caps Lock remapped by System Settings does not reliably carry a
device-specific modifier bit, so matching one physical key is not an option on
this route.

### Option B — hidutil LaunchAgent

Maps Caps Lock to **Right** Control, so the physical Left Control key keeps its
ordinary behavior. Set `CAPS_IS = "right"` in `init.lua`, then:

```sh
cp local.hidutil.capslock.plist ~/Library/LaunchAgents/
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/local.hidutil.capslock.plist
```

Copying the plist is not enough on its own. launchd only reads it at the next
login, or when bootstrapped as above. `launchctl load` is the legacy command and
fails quietly on current macOS.

Confirm with `hidutil property --get "UserKeyMapping"`. Expect `Src 30064771129`
(Caps Lock, HID usage 0x39) and `Dst 30064771300` (Right Control, usage 0xE4).
A result of `(null)` means the agent never ran.

## Install

```sh
brew install --cask hammerspoon
mkdir -p ~/.hammerspoon

curl -fsSL -o ~/.hammerspoon/init.lua \
  https://raw.githubusercontent.com/<redacted>/dotfiles-dipper-transfer/main/.config/keyboard-hammerspoon-fallback/init.lua

open -a Hammerspoon
```

Then grant Hammerspoon **Accessibility** access in System Settings, Privacy and
Security, Accessibility. Nothing works until that is granted. After granting it,
use the Hammerspoon menu bar icon and choose Reload Config.

Verify it is alive: `pgrep -x Hammerspoon`.

## Known limits

- Event taps do not fire at the login window, and macOS suppresses them during
  secure input such as password fields.
- `hidutil` mappings are not persistent, which is why Option B needs a
  LaunchAgent to reapply the mapping at each login.
- Slightly higher latency than a driver-level remap.
- Not included: the `left_ctrl + left_cmd + h/j/k/l` vim arrow rule, which also
  lives in the Karabiner config. Ask if that is wanted here too.
