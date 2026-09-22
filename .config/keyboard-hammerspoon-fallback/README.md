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

## Files

- `init.lua` — install to `~/.hammerspoon/init.lua`
- `local.hidutil.capslock.plist` — install to `~/Library/LaunchAgents/`

## Install

```sh
brew install --cask hammerspoon

mkdir -p ~/.hammerspoon ~/Library/LaunchAgents
cp ~/.config/keyboard-hammerspoon-fallback/init.lua ~/.hammerspoon/init.lua
cp ~/.config/keyboard-hammerspoon-fallback/local.hidutil.capslock.plist ~/Library/LaunchAgents/

launchctl load ~/Library/LaunchAgents/local.hidutil.capslock.plist
open -a Hammerspoon
```

Then grant Hammerspoon **Accessibility** access in System Settings, Privacy and
Security, Accessibility. The rules do not work until that is granted.

## Verify

```sh
hidutil property --get "UserKeyMapping"
```

Expect one entry, `Src 30064771129` (Caps Lock, HID usage 0x39) mapped to
`Dst 30064771300` (Right Control, usage 0xE4).

## Design note

`hidutil` remaps Caps Lock to **Right** Control rather than Left. Hammerspoon
keys its tap detection off Right Control, so the physical Left Control key keeps
its ordinary behavior. The original Karabiner rule made both keys dual-role, so
tapping real Left Control there also produced Escape.

## Known limits

- Event taps do not fire at the login window, and macOS suppresses them during
  secure input such as password fields.
- `hidutil` mappings are not persistent, which is why the LaunchAgent reapplies
  the mapping at each login.
- Slightly higher latency than a driver-level remap.
- Not included: the `left_ctrl + left_cmd + h/j/k/l` vim arrow rule, which also
  lives in the Karabiner config. Ask if that is wanted here too.
