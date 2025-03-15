on scriptRun(argsCmd)
    set withCmd to (argsCmd)
    tell application "iTerm"
        reopen
        activate
        tell the current window
            tell the current session
                write text withCmd
            end tell
        end tell
    end tell
end scriptRun
