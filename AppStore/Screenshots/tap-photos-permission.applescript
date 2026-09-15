#!/usr/bin/osascript
-- Tap the in-app Photos button and the system permission alert inside Simulator.
tell application "Simulator" to activate
delay 0.6
tell application "System Events"
  tell process "Simulator"
    set frontmost to true
    delay 0.2
    try
      click button "Allow Photos Access" of window 1
      delay 1.0
    end try
    try
      -- iOS Photos permission sheet, various OS wordings.
      if exists button "Allow Full Access" of window 1 then
        click button "Allow Full Access" of window 1
      else if exists button "Allow Access to All Photos" of window 1 then
        click button "Allow Access to All Photos" of window 1
      else if exists button "Allow" of window 1 then
        click button "Allow" of window 1
      end if
    end try
  end tell
end tell
