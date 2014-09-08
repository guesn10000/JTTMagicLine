//
//  JTTJTTMagicLine.m
//  JTTMagicLine
//
//  Created by Jymn_Chen on 14-9-8.
//  Copyright (c) 2014年 Jymn_Chen. All rights reserved.
//

#import "JTTJTTMagicLine.h"

static JTTJTTMagicLine *sharedInstance;

@interface JTTJTTMagicLine ()

@property (nonatomic, strong) NSBundle *bundle;

@end

@implementation JTTJTTMagicLine

+ (void)pluginDidLoad:(NSBundle *)plugin {
    static dispatch_once_t onceToken;
    NSString *currentApplicationName = [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];
    if ([currentApplicationName isEqual:@"Xcode"]) {
        dispatch_once(&onceToken, ^{
            sharedInstance = [[self alloc] initWithBundle:plugin];
        });
    }
}

- (id)initWithBundle:(NSBundle *)plugin {
    if (self = [super init]) {
        // reference to plugin's bundle, for resource acccess
        self.bundle = plugin;
        
        NSMenuItem *menuItem = [[NSApp mainMenu] itemWithTitle:@"File"];
        if (menuItem) {
            [[menuItem submenu] addItem:[NSMenuItem separatorItem]];
            NSMenuItem *actionMenuItem = [[NSMenuItem alloc] initWithTitle:@"ff" action:@selector(doMenuAction) keyEquivalent:@""];
            [actionMenuItem setTarget:self];
            [[menuItem submenu] addItem:actionMenuItem];
        }
        
//        [[NSNotificationCenter defaultCenter] addObserver:self
//                                                 selector:@selector(textStorageDidChange:)
//                                                     name:NSTextDidChangeNotification
//                                                   object:nil];
//        [self addSettingMenu];
    }
    return self;
}

//+ (instancetype)sharedInstance {
//    static dispatch_once_t onceToken;
//    static id instance = nil;
//    dispatch_once(&onceToken, ^{
//        instance = [[[self class] alloc] init];
//    });
//    return instance;
//}

//- (instancetype)init {
//    self = [super init];
//    if (self) {
//        [[NSNotificationCenter defaultCenter] addObserver:self
//                                                 selector:@selector(applicationDidFinishLaunching:)
//                                                     name:NSApplicationDidFinishLaunchingNotification
//                                                   object:nil];
//    }
//    return self;
//}

//- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(textStorageDidChange:)
//                                                 name:NSTextDidChangeNotification
//                                               object:nil];
//    [self addSettingMenu];
//}

- (void)addSettingMenu {
    NSMenuItem *editMenuItem = [[NSApp mainMenu] itemWithTitle:@"Window"];
    if (editMenuItem) {
        [[editMenuItem submenu] addItem:[NSMenuItem separatorItem]];
        
        NSMenuItem *newMenuItem = [[NSMenuItem alloc] initWithTitle:@"JTTMagicLine" action:@selector(showSettingPanel:) keyEquivalent:@""];
        
        [newMenuItem setTarget:self];
        [[editMenuItem submenu] addItem:newMenuItem];
    }
}

@end
