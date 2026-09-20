#!/bin/bash
osascript <<EOF
tell application "System Events"
    delay .10
    key code 22 using control down
end tell 
EOF
