on scriptRun(argsCmd, argsTheme, argsTitle)
    set withCmd to (argsCmd)
    set withTheme to (argsTheme)
    set theTitle to (argsTitle)
    tell application "Terminal"
        activate
        tell application "System Events"
            tell process "Terminal"
                keystroke "t" using {command down}
            end tell
        end tell
        do script withCmd in front window
        try
            set current settings of front window to settings set withTheme
        end try
        set custom title of front window to theTitle
    end tell
end scriptRun
