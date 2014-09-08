//
//  NSTextView+JTTTextGetter.m
//  JTTMagicLine
//
//  Created by Jymn_Chen on 14-9-8.
//  Copyright (c) 2014年 Jymn_Chen. All rights reserved.
//

#import "NSTextView+JTTTextGetter.h"
#import "JTTTextResult.h"
#import "NSString+JTTTextGetter.h"

@implementation NSTextView (JTTTextGetter)

- (NSInteger)jtt_currentCurseLocation {
    return [[self selectedRanges][0] rangeValue].location;
}

- (JTTTextResult *)jtt_textResultOfCurrentLine {
    return [self.textStorage.string jtt_textResultOfCurrentLineCurrentLocation:[self jtt_currentCurseLocation]];
}

@end
