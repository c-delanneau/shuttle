on scriptRun(argsCmd, argsTheme, argsTitle)
    set withCmd to (argsCmd)
    set withTheme to (argsTheme)
    set theTitle to (argsTitle)
    tell application "iTerm"
        activate
        create window with default profile
        tell current session of current window
            set name to theTitle
            write text withCmd
        end tell
    end tell
end scriptRun
