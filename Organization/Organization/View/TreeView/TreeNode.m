//
//  TreeNode.m
//  opentok
//
//  Created by Openit on 2016. 6. 22..
//  Copyright © 2016년 openit. All rights reserved.
//

#import "TreeNode.h"

@implementation TreeNode

@synthesize PARENT_DEPT_CD, DEPT_CD, DEPT_NAME;
@synthesize IS_LAST_SIBLING;
@synthesize TREE_LEVEL;
@synthesize imageMapArray;
@synthesize imageIndexArray;
@synthesize memberListArray;
@synthesize LeftChild, RightSibling;

- (id) init {
    self = [super init];
    if (self) {
        imageMapArray = [[NSMutableArray alloc] init];
        imageIndexArray = [[NSMutableArray alloc] init];
        memberListArray = [[NSMutableArray alloc] init];
    }
    return self;
}

@end
