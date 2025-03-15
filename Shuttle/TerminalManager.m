//
//  TerminalManager.m
//  Shuttle
//

#import <Foundation/Foundation.h>
#import "TerminalManager.h"

@implementation TerminalManager

+ (instancetype)sharedManager {
    static TerminalManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (void)executeCommand:(NSString *)command 
          terminalType:(TerminalType)terminalType 
            windowMode:(WindowMode)windowMode 
                 theme:(NSString *)theme 
                 title:(NSString *)title {
    
    // 处理虚拟模式（后台执行）
    if (windowMode == WindowModeVirtual) {
        [self executeCommandInBackground:command title:title];
        return;
    }
    
    // 根据终端类型执行不同的操作
    switch (terminalType) {
        case TerminalTypeDefault:
            [self executeInTerminal:command windowMode:windowMode theme:theme title:title];
            break;
            
        case TerminalTypeITerm:
        case TerminalTypeITermNightly:
            [self executeInITerm:command windowMode:windowMode theme:theme title:title];
            break;
    }
}

- (void)executeInTerminal:(NSString *)command windowMode:(WindowMode)windowMode theme:(NSString *)theme title:(NSString *)title {
    NSString *script;
    
    // 准备终端的不同执行模式
    if (windowMode == WindowModeNew) {
        // 在新窗口中执行
        script = [NSString stringWithFormat:@"tell application \"Terminal\"\n"
                  "  activate\n"
                  "  do script \"\"\n"
                  "  set newWindow to front window\n"
                  "  do script \"%@\" in newWindow\n"
                  "  try\n"
                  "    set current settings of newWindow to settings set \"%@\"\n"
                  "  end try\n"
                  "  set custom title of newWindow to \"%@\"\n"
                  "end tell", 
                  [self escapeString:command], 
                  [self escapeString:theme], 
                  [self escapeString:title]];
    } else if (windowMode == WindowModeCurrent) {
        // 在当前窗口中执行
        script = [NSString stringWithFormat:@"tell application \"Terminal\"\n"
                  "  reopen\n"
                  "  activate\n"
                  "  do script \"%@\" in front window\n"
                  "end tell", 
                  [self escapeString:command]];
    } else { // WindowModeTab
        // 在新标签页中执行
        script = [NSString stringWithFormat:@"tell application \"Terminal\"\n"
                  "  activate\n"
                  "  tell application \"System Events\"\n"
                  "    tell process \"Terminal\"\n"
                  "      keystroke \"t\" using {command down}\n"
                  "    end tell\n"
                  "  end tell\n"
                  "  do script \"%@\" in front window\n"
                  "  set current settings of front window to settings set \"%@\"\n"
                  "  set custom title of front window to \"%@\"\n"
                  "end tell", 
                  [self escapeString:command], 
                  [self escapeString:theme], 
                  [self escapeString:title]];
    }
    
    // 使用 NSAppleScript 执行脚本，而不是依赖外部 .scpt 文件
    NSAppleScript *appleScript = [[NSAppleScript alloc] initWithSource:script];
    NSDictionary *error = nil;
    [appleScript executeAndReturnError:&error];
    
    if (error) {
        NSLog(@"Error executing Terminal script: %@", error);
    }
}

- (void)executeInITerm:(NSString *)command windowMode:(WindowMode)windowMode theme:(NSString *)theme title:(NSString *)title {
    NSString *script;
    
    // 准备 iTerm 的不同执行模式
    if (windowMode == WindowModeNew) {
        // 在新窗口中执行
        script = [NSString stringWithFormat:@"tell application \"iTerm\"\n"
                  "  activate\n"
                  "  try\n"
                  "    create window with profile \"%@\"\n"
                  "  on error\n"
                  "    create window with profile \"Default\"\n"
                  "  end try\n"
                  "  tell the current window\n"
                  "    tell the current session\n"
                  "      set name to \"%@\"\n"
                  "      write text \"%@\"\n"
                  "    end tell\n"
                  "  end tell\n"
                  "end tell", 
                  [self escapeString:theme], 
                  [self escapeString:title], 
                  [self escapeString:command]];
    } else if (windowMode == WindowModeCurrent) {
        // 在当前窗口中执行
        script = [NSString stringWithFormat:@"tell application \"iTerm\"\n"
                  "  reopen\n"
                  "  activate\n"
                  "  tell the current window\n"
                  "    tell the current session\n"
                  "      write text \"%@\"\n"
                  "    end tell\n"
                  "  end tell\n"
                  "end tell", 
                  [self escapeString:command]];
    } else { // WindowModeTab
        // 在新标签页中执行
        script = [NSString stringWithFormat:@"tell application \"iTerm\"\n"
                  "  activate\n"
                  "  tell the current window\n"
                  "    try\n"
                  "      create tab with profile \"%@\"\n"
                  "    on error\n"
                  "      create tab with profile \"Default\"\n"
                  "    end try\n"
                  "    tell the current tab\n"
                  "      tell the current session\n"
                  "        set name to \"%@\"\n"
                  "        write text \"%@\"\n"
                  "      end tell\n"
                  "    end tell\n"
                  "  end tell\n"
                  "end tell", 
                  [self escapeString:theme], 
                  [self escapeString:title], 
                  [self escapeString:command]];
    }
    
    // 使用 NSAppleScript 执行脚本，而不是依赖外部 .scpt 文件
    NSAppleScript *appleScript = [[NSAppleScript alloc] initWithSource:script];
    NSDictionary *error = nil;
    [appleScript executeAndReturnError:&error];
    
    if (error) {
        NSLog(@"Error executing iTerm script: %@", error);
    }
}

- (void)executeCommandInBackground:(NSString *)command title:(NSString *)title {
    // 使用 NSTask 替代 screen 命令
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/usr/bin/screen"];
    
    // 构建 screen 命令参数
    NSArray *arguments = @[@"-d", @"-m", @"-S", title, @"/bin/sh", @"-c", command];
    [task setArguments:arguments];
    
    // 启动任务
    NSError *error = nil;
    if (![task launchAndReturnError:&error]) {
        NSLog(@"Error executing background command: %@", error);
    }
}

// 辅助方法：转义字符串用于 AppleScript
- (NSString *)escapeString:(NSString *)string {
    if (!string) return @"";
    
    NSString *escaped = [string stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
    escaped = [escaped stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    escaped = [escaped stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
    escaped = [escaped stringByReplacingOccurrencesOfString:@"\r" withString:@"\\r"];
    escaped = [escaped stringByReplacingOccurrencesOfString:@"\t" withString:@"\\t"];
    
    return escaped;
}

- (void)executeCommandDirectly:(NSString *)command 
                  terminalType:(TerminalType)terminalType 
                    windowMode:(WindowMode)windowMode 
                         theme:(NSString *)theme 
                         title:(NSString *)title {
    
    if (terminalType == TerminalTypeDefault) {
        // 执行 Terminal.app 命令
        [self executeInTerminalDirectly:command windowMode:windowMode theme:theme title:title];
    } else {
        // 执行 iTerm 命令
        [self executeInITermDirectly:command windowMode:windowMode theme:theme title:title];
    }
}

- (NSString *)escapeShellCommand:(NSString *)command {
    // 转义单引号
    NSString *escaped = [command stringByReplacingOccurrencesOfString:@"'" withString:@"'\\''"];
    // 确保转义其他特殊字符
    return escaped;
}

- (void)executeInITermDirectly:(NSString *)command windowMode:(WindowMode)windowMode theme:(NSString *)theme title:(NSString *)title {
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/usr/bin/open"];
    
    NSMutableArray *arguments = [NSMutableArray array];
    
    if (windowMode == WindowModeNew) {
        // 打开新窗口
        [arguments addObject:@"-a"];
        [arguments addObject:@"iTerm"];
        
        // 创建临时脚本文件
        NSString *tempScript = [NSTemporaryDirectory() stringByAppendingPathComponent:@"shuttle_iterm_script.command"];
        
        // 使用上次选择的配置文件或默认配置文件
        NSString *profileOption = theme ? [NSString stringWithFormat:@" -p \"%@\"", theme] : @"";
        
        // 构建脚本内容
        NSString *scriptContent = [NSString stringWithFormat:@"#!/bin/bash\n"
                                   "osascript -e 'tell application \"iTerm\"\n"
                                   "  create window with default profile%@\n"
                                   "  tell current window\n"
                                   "    tell current session\n"
                                   "      set name to \"%@\"\n"
                                   "      write text \"%@\"\n"
                                   "    end tell\n"
                                   "  end tell\n"
                                   "end tell'\n", 
                                   profileOption, title, [self escapeShellCommand:command]];
        
        [scriptContent writeToFile:tempScript atomically:YES encoding:NSUTF8StringEncoding error:nil];
        
        // 设置临时脚本可执行
        NSTask *chmodTask = [[NSTask alloc] init];
        [chmodTask setLaunchPath:@"/bin/chmod"];
        [chmodTask setArguments:@[@"+x", tempScript]];
        [chmodTask launch];
        [chmodTask waitUntilExit];
        
        [arguments addObject:tempScript];
    } else if (windowMode == WindowModeTab) {
        // 对于标签页模式
        NSString *osascriptCommand = [NSString stringWithFormat:@"tell application \"iTerm\"\n"
                                      "  tell current window\n"
                                      "    create tab with default profile\n"
                                      "    tell current session\n"
                                      "      set name to \"%@\"\n"
                                      "      write text \"%@\"\n"
                                      "    end tell\n"
                                      "  end tell\n"
                                      "end tell", 
                                      title, [self escapeShellCommand:command]];
        
        NSTask *osascriptTask = [[NSTask alloc] init];
        [osascriptTask setLaunchPath:@"/usr/bin/osascript"];
        [osascriptTask setArguments:@[@"-e", osascriptCommand]];
        [osascriptTask launch];
        return;
    } else {
        // 对于当前窗口模式
        NSString *osascriptCommand = [NSString stringWithFormat:@"tell application \"iTerm\"\n"
                                      "  tell current window\n"
                                      "    tell current session\n"
                                      "      write text \"%@\"\n"
                                      "    end tell\n"
                                      "  end tell\n"
                                      "end tell", 
                                      [self escapeShellCommand:command]];
        
        NSTask *osascriptTask = [[NSTask alloc] init];
        [osascriptTask setLaunchPath:@"/usr/bin/osascript"];
        [osascriptTask setArguments:@[@"-e", osascriptCommand]];
        [osascriptTask launch];
        return;
    }
    
    [task setArguments:arguments];
    [task launch];
}

@end
