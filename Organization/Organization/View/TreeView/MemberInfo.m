//
//  MemberInfo.m
//  opentok
//
//  Created by Openit on 2016. 6. 22..
//  Copyright © 2016년 openit. All rights reserved.
//

#import "MemberInfo.h"

@implementation MemberInfo

@synthesize imageMapArray, imageIndexArray;
@synthesize DEPT_CD, KOR_NAME, MEMBER_SEQ, POSITION_CD, POSITION_NAME, POSITION_ORDER, IS_LAST;

- (id)init {
    self = [super init];
    if (self) {
        imageMapArray = [[NSMutableArray alloc] init];
        imageIndexArray = [[NSMutableArray alloc] init];
        IS_LAST = NO;
    }
    return self;
}

@end
