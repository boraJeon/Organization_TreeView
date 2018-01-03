//
//  TreeManager.h
//  opentok
//
//  Created by Openit on 2016. 6. 22..
//  Copyright © 2016년 openit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TreeNode.h"

@interface TreeManager : NSObject {
    TreeNode *rootNode;
}

@property (strong, nonatomic) TreeNode *rootNode;

@property (strong, nonatomic) NSMutableArray *totalDataList;
@property (strong, nonatomic) NSMutableArray *deptList;
@property (strong, nonatomic) NSMutableArray *memberList;
@property (strong, nonatomic) NSMutableArray *nodeList;
@property (strong, nonatomic) NSMutableArray *tempParentList;

-(void)CreateOrgTree:(NSMutableArray *)deptlist;
-(void) PrintTree:(TreeNode *)node;

@end
