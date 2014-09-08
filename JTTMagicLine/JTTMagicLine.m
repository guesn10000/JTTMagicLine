//
//  JTTMagicLine.m
//  JTTMagicLine
//
//  Created by Jymn_Chen on 14-9-8.
//  Copyright (c) 2014年 Jymn_Chen. All rights reserved.
//

#import "JTTMagicLine.h"

@implementation JTTMagicLine

+ (NSString *)magicLine {
    NSMutableString *magicLine = [NSMutableString string];
    NSString *seperator = @"/";
    for (NSInteger i = 0; i < 91; i++) {
        [magicLine appendString:seperator];
    }
    return [magicLine copy];
}

@end
