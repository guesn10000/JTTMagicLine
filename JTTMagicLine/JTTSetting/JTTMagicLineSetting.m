//
//  JTTMagicLineSetting.m
//  JTTMagicLine
//
//  Created by Jymn_Chen on 14-9-8.
//  Copyright (c) 2014年 Jymn_Chen. All rights reserved.
//

#import "JTTMagicLineSetting.h"
#import <Carbon/Carbon.h>

NSString * const JTTDefaultTriggerString = @"mgl";

NSString * const kJTTTriggerString = @"JTTDefaultTriggerStringKey";

@implementation JTTMagicLineSetting

+ (JTTMagicLineSetting *)defaultSetting {
    static dispatch_once_t onceToken;
    static id defaultSetting;
    dispatch_once(&onceToken, ^ {
        defaultSetting = [[[self class] alloc] init];
        
        NSDictionary *defaults = @{kJTTTriggerString : JTTDefaultTriggerString};
        [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
    });
    return defaultSetting;
}

- (NSString *)triggerString {
    NSString *s = [[NSUserDefaults standardUserDefaults] stringForKey:kJTTTriggerString];
    if (s.length == 0) {
        s = JTTDefaultTriggerString;
    }
    return s;
}

- (BOOL)useDvorakLayout {
    TISInputSourceRef inputSource = TISCopyCurrentKeyboardLayoutInputSource();
    NSString *layoutID = (__bridge NSString *)TISGetInputSourceProperty(inputSource, kTISPropertyInputSourceID);
    CFRelease(inputSource);
    
    if ([layoutID rangeOfString:@"Dvorak" options:NSCaseInsensitiveSearch].location != NSNotFound) {
        return YES;
    }
    else {
        return NO;
    }
}

@end
