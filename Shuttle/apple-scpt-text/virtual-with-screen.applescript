on scriptRun(argsCmd, argsTitle)
    set screenSwitches to "screen -d -m -S "
    set screenSessionName to "'" & argsTitle & "' "
    set withCmd to screenSwitches & screenSessionName & argsCmd
    do shell script withCmd
end scriptRun
