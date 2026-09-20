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

# com.apple.dock
defaults write com.apple.dock "autohide" -bool true
defaults write com.apple.dock "autohide-delay" -int 0
defaults write com.apple.dock "autohide-time-modifier" -float 0.4
defaults write com.apple.dock "magnification" -bool true
defaults write com.apple.dock "tilesize" -float 62
defaults write com.apple.dock "largesize" -float 62
defaults write com.apple.dock "mineffect" -string "genie"
defaults write com.apple.dock "orientation" -string "bottom"
defaults write com.apple.dock "mru-spaces" -bool false
defaults write com.apple.dock "show-recents" -bool false
defaults write com.apple.dock "showAppExposeGestureEnabled" -bool false
defaults write com.apple.dock "wvous-tl-corner" -int 4
defaults write com.apple.dock "wvous-tl-modifier" -int 0
defaults write com.apple.dock "wvous-tr-corner" -int 2
defaults write com.apple.dock "wvous-tr-modifier" -int 0
defaults write com.apple.dock "wvous-bl-corner" -int 10
defaults write com.apple.dock "wvous-bl-modifier" -int 0
defaults write com.apple.dock "wvous-br-corner" -int 11
defaults write com.apple.dock "wvous-br-modifier" -int 0

# com.apple.finder
defaults write com.apple.finder "ShowPathbar" -bool true
defaults write com.apple.finder "ShowStatusBar" -bool true
defaults write com.apple.finder "FXPreferredViewStyle" -string "Nlsv"
defaults write com.apple.finder "FXDefaultSearchScope" -string "SCcf"
defaults write com.apple.finder "ShowHardDrivesOnDesktop" -bool true
defaults write com.apple.finder "ShowExternalHardDrivesOnDesktop" -bool true
defaults write com.apple.finder "ShowRemovableMediaOnDesktop" -bool true

# NSGlobalDomain
defaults write NSGlobalDomain "KeyRepeat" -int 2
defaults write NSGlobalDomain "InitialKeyRepeat" -int 25
defaults write NSGlobalDomain "ApplePressAndHoldEnabled" -bool false
defaults write NSGlobalDomain "AppleShowAllExtensions" -bool true
defaults write NSGlobalDomain "AppleInterfaceStyle" -string "Dark"
defaults write NSGlobalDomain "AppleShowScrollBars" -string "Automatic"
defaults write NSGlobalDomain "NSAutomaticSpellingCorrectionEnabled" -bool true
defaults write NSGlobalDomain "NSAutomaticCapitalizationEnabled" -bool false
defaults write NSGlobalDomain "NSAutomaticDashSubstitutionEnabled" -bool true
defaults write NSGlobalDomain "NSAutomaticQuoteSubstitutionEnabled" -bool true
defaults write NSGlobalDomain "NSAutomaticPeriodSubstitutionEnabled" -bool false
defaults write NSGlobalDomain "com.apple.swipescrolldirection" -bool true
defaults write NSGlobalDomain "com.apple.springing.enabled" -bool true
defaults write NSGlobalDomain "com.apple.trackpad.scaling" -float 2

# com.apple.AppleMultitouchTrackpad
defaults write com.apple.AppleMultitouchTrackpad "Clicking" -bool true
defaults write com.apple.AppleMultitouchTrackpad "TrackpadThreeFingerDrag" -bool true
defaults write com.apple.AppleMultitouchTrackpad "ActuationStrength" -int 1
defaults write com.apple.AppleMultitouchTrackpad "FirstClickThreshold" -int 1
defaults write com.apple.AppleMultitouchTrackpad "SecondClickThreshold" -int 1

# com.apple.driver.AppleBluetoothMultitouch.trackpad
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad "Clicking" -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad "TrackpadThreeFingerDrag" -bool true

# com.apple.WindowManager
defaults write com.apple.WindowManager "GloballyEnabled" -bool false

# com.apple.spaces
defaults write com.apple.spaces "spans-displays" -bool false

# com.apple.universalaccess
defaults write com.apple.universalaccess "reduceMotion" -bool true
defaults write com.apple.universalaccess "reduceTransparency" -bool false

# Restart the affected services so the changes take effect.
killall Dock 2>/dev/null || true
killall Finder 2>/dev/null || true

# Trackpad and keyboard changes may need a log out and back in to fully apply.
echo "macOS preferences applied."
