#!/bin/bash
osascript <<EOF
tell application "System Events"
    delay .10
    key code 18 using control down
end tell 
EOF
