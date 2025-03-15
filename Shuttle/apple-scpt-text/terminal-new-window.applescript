on scriptRun(argsCmd, argsTheme, argsTitle)
    set withCmd to (argsCmd)
    set withTheme to (argsTheme)
    set theTitle to (argsTitle)
    tell application "Terminal"
        activate
        do script ""
        set newWindow to front window
        do script withCmd in newWindow
        try
            set current settings of newWindow to settings set withTheme
        end try
        set custom title of newWindow to theTitle
    end tell
end scriptRun
