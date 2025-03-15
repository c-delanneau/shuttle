#!/bin/bash

# 创建 iTerm2 脚本
cat > Shuttle/apple-scpt/iTerm2-stable-current-window.scpt << 'SCRIPT'
-- 这是 iTerm2 当前窗口脚本
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
SCRIPT

cat > Shuttle/apple-scpt/iTerm2-stable-new-tab-default.scpt << 'SCRIPT'
-- 这是 iTerm2 新标签页脚本
on scriptRun(argsCmd, argsTheme, argsTitle)
    set withCmd to (argsCmd)
    set withTheme to (argsTheme)
    set theTitle to (argsTitle)
    tell application "iTerm"
        activate
        try
            set newTab to (create tab with default profile in current window)
            tell current session of current tab of current window
                set name to theTitle
                write text withCmd
            end tell
        on error
            create window with default profile
            tell current session of current window
                set name to theTitle
                write text withCmd
            end tell
        end try
    end tell
end scriptRun
SCRIPT

cat > Shuttle/apple-scpt/iTerm2-stable-new-window.scpt << 'SCRIPT'
-- 这是 iTerm2 新窗口脚本
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
SCRIPT

cat > Shuttle/apple-scpt/iTerm2-nightly-current-window.scpt << 'SCRIPT'
-- 这是 iTerm2 Nightly 当前窗口脚本
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
SCRIPT

cat > Shuttle/apple-scpt/iTerm2-nightly-new-tab-default.scpt << 'SCRIPT'
-- 这是 iTerm2 Nightly 新标签页脚本
on scriptRun(argsCmd, argsTheme, argsTitle)
    set withCmd to (argsCmd)
    set withTheme to (argsTheme)
    set theTitle to (argsTitle)
    tell application "iTerm"
        activate
        try
            set newTab to (create tab with default profile in current window)
            tell current session of current tab of current window
                set name to theTitle
                write text withCmd
            end tell
        on error
            create window with default profile
            tell current session of current window
                set name to theTitle
                write text withCmd
            end tell
        end try
    end tell
end scriptRun
SCRIPT

cat > Shuttle/apple-scpt/iTerm2-nightly-new-window.scpt << 'SCRIPT'
-- 这是 iTerm2 Nightly 新窗口脚本
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
SCRIPT

# 创建 Terminal 脚本
cat > Shuttle/apple-scpt/terminal-current-window.scpt << 'SCRIPT'
-- 这是 Terminal 当前窗口脚本
on scriptRun(argsCmd)
    set withCmd to (argsCmd)
    tell application "Terminal"
        reopen
        activate
        do script withCmd in front window
    end tell
end scriptRun
SCRIPT

cat > Shuttle/apple-scpt/terminal-new-tab-default.scpt << 'SCRIPT'
-- 这是 Terminal 新标签页脚本
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
        set current settings of front window to settings set withTheme
        set custom title of front window to theTitle
    end tell
end scriptRun
SCRIPT

cat > Shuttle/apple-scpt/terminal-new-window.scpt << 'SCRIPT'
-- 这是 Terminal 新窗口脚本
on scriptRun(argsCmd, argsTheme, argsTitle)
    set withCmd to (argsCmd)
    set withTheme to (argsTheme)
    set theTitle to (argsTitle)
    tell application "Terminal"
        activate
        do script ""
        set newWindow to front window
        do script withCmd in newWindow
        set current settings of newWindow to settings set withTheme
        set custom title of newWindow to theTitle
    end tell
end scriptRun
SCRIPT

# 创建 Virtual Screen 脚本
cat > Shuttle/apple-scpt/virtual-with-screen.scpt << 'SCRIPT'
-- 这是 Virtual Screen 脚本
on scriptRun(argsCmd, argsTitle)
    set screenSwitches to "screen -d -m -S "
    set screenSessionName to "'" & argsTitle & "' "
    set withCmd to screenSwitches & screenSessionName & argsCmd
    do shell script withCmd
end scriptRun
SCRIPT
