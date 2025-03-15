on scriptRun(argsCmd)
    set withCmd to (argsCmd)
    tell application "Terminal"
        reopen
        activate
        do script withCmd in front window
    end tell
end scriptRun
