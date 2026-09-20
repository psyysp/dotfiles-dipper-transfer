#!/usr/bin/env bash
#
# macOS preferences, captured by `dotdipper macos capture`.
# Generated file — re-run the command rather than editing it.
#
# Only an explicit allowlist of individual keys is captured, and only scalar
# values. No preference plist is ever copied: Finder and Dock plists carry
# recent-folder names, absolute home paths, and the pinned app lineup, none
# of which belong in a dotfiles repository.
#
# Re-running is safe; every line is idempotent.

set -uo pipefail

if [ "$(uname -s)" != "Darwin" ]; then
  echo "macos defaults: not macOS, nothing to do." >&2
  exit 0
fi

REFUSED=()

# Some domains are protected by TCC, not by file permissions, and
# `com.apple.universalaccess` is the common one: the write fails no matter who
# runs it until the terminal has Full Disk Access. sudo does not help. Record
# the refusal and keep going, so one protected domain cannot quietly cost you
# every setting after it.
set_default() {
  local domain="$1" key="$2"
  shift 2
  if ! defaults write "$domain" "$key" "$@" 2>/dev/null; then
    REFUSED+=("$domain $key")
  fi
}

# com.apple.dock
set_default com.apple.dock "autohide" -bool true
set_default com.apple.dock "autohide-delay" -int 0
set_default com.apple.dock "autohide-time-modifier" -float 0.4
set_default com.apple.dock "magnification" -bool true
set_default com.apple.dock "tilesize" -float 62
set_default com.apple.dock "largesize" -float 62
set_default com.apple.dock "mineffect" -string "genie"
set_default com.apple.dock "orientation" -string "bottom"
set_default com.apple.dock "mru-spaces" -bool false
set_default com.apple.dock "show-recents" -bool false
set_default com.apple.dock "showAppExposeGestureEnabled" -bool false
set_default com.apple.dock "wvous-tl-corner" -int 4
set_default com.apple.dock "wvous-tl-modifier" -int 0
set_default com.apple.dock "wvous-tr-corner" -int 2
set_default com.apple.dock "wvous-tr-modifier" -int 0
set_default com.apple.dock "wvous-bl-corner" -int 10
set_default com.apple.dock "wvous-bl-modifier" -int 0
set_default com.apple.dock "wvous-br-corner" -int 11
set_default com.apple.dock "wvous-br-modifier" -int 0

# com.apple.finder
set_default com.apple.finder "ShowPathbar" -bool true
set_default com.apple.finder "ShowStatusBar" -bool true
set_default com.apple.finder "FXPreferredViewStyle" -string "Nlsv"
set_default com.apple.finder "FXDefaultSearchScope" -string "SCcf"
set_default com.apple.finder "ShowHardDrivesOnDesktop" -bool true
set_default com.apple.finder "ShowExternalHardDrivesOnDesktop" -bool true
set_default com.apple.finder "ShowRemovableMediaOnDesktop" -bool true

# NSGlobalDomain
set_default NSGlobalDomain "KeyRepeat" -int 2
set_default NSGlobalDomain "InitialKeyRepeat" -int 25
set_default NSGlobalDomain "ApplePressAndHoldEnabled" -bool false
set_default NSGlobalDomain "AppleShowAllExtensions" -bool true
set_default NSGlobalDomain "AppleInterfaceStyle" -string "Dark"
set_default NSGlobalDomain "AppleShowScrollBars" -string "Automatic"
set_default NSGlobalDomain "NSAutomaticSpellingCorrectionEnabled" -bool true
set_default NSGlobalDomain "NSAutomaticCapitalizationEnabled" -bool false
set_default NSGlobalDomain "NSAutomaticDashSubstitutionEnabled" -bool true
set_default NSGlobalDomain "NSAutomaticQuoteSubstitutionEnabled" -bool true
set_default NSGlobalDomain "NSAutomaticPeriodSubstitutionEnabled" -bool false
set_default NSGlobalDomain "com.apple.swipescrolldirection" -bool true
set_default NSGlobalDomain "com.apple.springing.enabled" -bool true
set_default NSGlobalDomain "com.apple.trackpad.scaling" -float 2

# com.apple.AppleMultitouchTrackpad
set_default com.apple.AppleMultitouchTrackpad "Clicking" -bool true
set_default com.apple.AppleMultitouchTrackpad "TrackpadThreeFingerDrag" -bool true
set_default com.apple.AppleMultitouchTrackpad "ActuationStrength" -int 1
set_default com.apple.AppleMultitouchTrackpad "FirstClickThreshold" -int 1
set_default com.apple.AppleMultitouchTrackpad "SecondClickThreshold" -int 1

# com.apple.driver.AppleBluetoothMultitouch.trackpad
set_default com.apple.driver.AppleBluetoothMultitouch.trackpad "Clicking" -bool true
set_default com.apple.driver.AppleBluetoothMultitouch.trackpad "TrackpadThreeFingerDrag" -bool true

# com.apple.WindowManager
set_default com.apple.WindowManager "GloballyEnabled" -bool false

# com.apple.spaces
set_default com.apple.spaces "spans-displays" -bool false

# com.apple.universalaccess
set_default com.apple.universalaccess "reduceMotion" -bool true
set_default com.apple.universalaccess "reduceTransparency" -bool false

# Restart the affected services so the changes take effect.
killall Dock 2>/dev/null || true
killall Finder 2>/dev/null || true

# Trackpad and keyboard changes may need a log out and back in to fully apply.
if [ ${#REFUSED[@]} -gt 0 ]; then
  echo "macOS preferences applied, except ${#REFUSED[@]} the system refused:" >&2
  for entry in "${REFUSED[@]}"; do echo "  $entry" >&2; done
  echo "These domains are protected by privacy controls, not permissions --" >&2
  echo "grant your terminal Full Disk Access and re-run. sudo will not help." >&2
else
  echo "macOS preferences applied."
fi
