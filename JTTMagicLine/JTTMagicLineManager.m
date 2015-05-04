//
//  JTTMagicLineManager.m
//  JTTMagicLine
//
//  Created by Jymn_Chen on 14-9-8.
//  Copyright (c) 2014年 Jymn_Chen. All rights reserved.
//

#import "JTTMagicLineManager.h"
#import "JTTMagicLine.h"
#import "JTTTextResult.h"
#import "NSTextView+JTTTextGetter.h"
#import "JTTMagicLineSetting.h"
#import "JTTSettingPanelWindowController.h"
#import "JTTKeyboardEventSender.h"

@interface JTTMagicLineManager ()

@property (nonatomic, strong) id eventMonitor;

/* 打开插件的设置面板 */
@property (nonatomic, strong) JTTSettingPanelWindowController *settingPanel;

@end

@implementation JTTMagicLineManager

/* 插件启动时创建JTTMagicLineManager单例对象 */
+ (void)pluginDidLoad:(NSBundle *)plugin {
    JTTLog(@"JTTMagicLine: Plugin loaded successfully");
    [[self class] sharedInstance];
}

/* 单例方法，调用初始化方法 */
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static id instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[[self class] alloc] init];
    });
    return instance;
}

/* 初始化方法，监听程序启动的消息 */
- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidFinishLaunching:)
                                                     name:NSApplicationDidFinishLaunchingNotification
                                                   object:nil];
    }
    return self;
}

/* 程序启动后，开始监听文字编辑区域中文字改变的消息，并在Xcode菜单中添加插件设置的菜单选项 */
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textStorageDidChange:)
                                                 name:NSTextDidChangeNotification
                                               object:nil];
    [self addSettingMenu];
}

/* 在Xcode菜单的Window选项中添加菜单选项：JTTMagicLine，点击后打开插件设置面板 */
- (void)addSettingMenu {
    NSMenuItem *editMenuItem = [[NSApp mainMenu] itemWithTitle:@"Window"];
    if (editMenuItem) {
        [[editMenuItem submenu] addItem:[NSMenuItem separatorItem]];
        
        NSMenuItem *newMenuItem = [[NSMenuItem alloc] initWithTitle:@"JTTMagicLine" action:@selector(showSettingPanel:) keyEquivalent:@""];
        
        [newMenuItem setTarget:self];
        [[editMenuItem submenu] addItem:newMenuItem];
    }
}

/* 在点击JTTMagicLine的菜单选项后，创建并打开插件设置面板 */
- (void)showSettingPanel:(NSNotification *)noti {
    self.settingPanel = [[JTTSettingPanelWindowController alloc] initWithWindowNibName:@"JTTSettingPanelWindowController"];
    [self.settingPanel showWindow:self.settingPanel];
}

/* Xcode编辑区域中的文字改变，在这里做Magic Line替换的工作 */
- (void)textStorageDidChange:(NSNotification *)aNotification {
    if (![[aNotification object] isKindOfClass:[NSTextView class]]) {
        return;
    }
    
    NSTextView *textView = (NSTextView *)[aNotification object];
    JTTTextResult *currentLineResult = [textView jtt_textResultOfCurrentLine];
    if (!currentLineResult) {
        return;
    }
    
    NSString *triggerString = [[JTTMagicLineSetting defaultSetting] triggerString];
    if (!triggerString) {
        return;
    }
    
    NSString *pattern = [NSString stringWithFormat:@"\\s*%@", triggerString];
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionAllowCommentsAndWhitespace error:&error];
    if (error) {
        return;
    }
    NSUInteger matches = [regex numberOfMatchesInString:currentLineResult.string options:0 range:NSMakeRange(0, currentLineResult.string.length)];
    if (matches <= 0) {
        return;
    }
    
    NSString *magicLine = [JTTMagicLine magicLine];
    if (!magicLine) {
        return;
    }
    
    // Save current content in paste board
    NSPasteboard *pasteBoard = [NSPasteboard generalPasteboard];
    NSString *originPBString = [pasteBoard stringForType:NSPasteboardTypeString];
    
    // Set the magic line in it
    [pasteBoard declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:nil];
    [pasteBoard setString:magicLine forType:NSStringPboardType];
    
    // Begin to simulate keyborad pressing
    JTTKeyboardEventSender *simKeyboard = [[JTTKeyboardEventSender alloc] init];
    [simKeyboard beginKeyBoradEvents];
    // Command + delete: delete current line
    [simKeyboard sendKeyCode:kVK_Delete withModifierCommand:YES alt:NO shift:NO control:NO];
    
    // Command + V, paste (If it is Dvorak layout, use '.', which is corresponding the key 'V' in a QWERTY layout)
    NSInteger kKeyVCode = [[JTTMagicLineSetting defaultSetting] useDvorakLayout] ? kVK_ANSI_Period : kVK_ANSI_V;
    [simKeyboard sendKeyCode:kKeyVCode withModifierCommand:YES alt:NO shift:NO control:NO];
    
    [simKeyboard sendKeyCode:kVK_Return];
    [simKeyboard sendKeyCode:kVK_Return];

    // The key down is just a defined finish signal by me. When we receive this key, we know operation above is finished.
    [simKeyboard sendKeyCode:kVK_F20];
    
    self.eventMonitor = [NSEvent addLocalMonitorForEventsMatchingMask:NSKeyDownMask
                                                              handler:^NSEvent *(NSEvent *incomingEvent) {
        if ([incomingEvent type] == NSKeyDown && [incomingEvent keyCode] == kVK_F20) {
            // Finish signal arrived, no need to observe the event
            [NSEvent removeMonitor:_eventMonitor];
            self.eventMonitor = nil;
            
            // Restore previois patse board content
            [pasteBoard declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:nil];
            [pasteBoard setString:originPBString forType:NSStringPboardType];
            
            // Set cursor before the inserted magic line. So we can use tab to begin edit.
            // int baseIndentationLength = (int)[doc baseIndentation].length;
            // [textView setSelectedRange:NSMakeRange(currentLineResult.range.location + baseIndentationLength, 0)];
            
            // Send a 'tab' after insert the doc. For our lazy programmers. :)
            // [kes sendKeyCode:kVK_Tab];
            [simKeyboard endKeyBoradEvents];
            
            // Invalidate the finish signal, in case you set it to do some other thing.
            return nil;
        }
        else if ([incomingEvent type] == NSKeyDown && [incomingEvent keyCode] == kKeyVCode) {
            // Select input line and the define code block.
            // NSRange r = [textView vv_textResultUntilNextString:@";"].range;
            
            // NSRange r begins from the starting of enum(struct) line. Select 1 character before to include the trigger input line.
            // [textView setSelectedRange:NSMakeRange(r.location - 1, r.length + 1)];
            return incomingEvent;
        }
        else {
            return incomingEvent;
        }
    }];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
