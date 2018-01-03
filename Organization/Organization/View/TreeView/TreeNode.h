//
//  TreeNode.h
//  opentok
//
//  Created by Openit on 2016. 6. 22..
//  Copyright © 2016년 openit. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TreeNode : NSObject {
    
}
@property (strong, nonatomic) TreeNode *LeftChild;
@property (strong, nonatomic) TreeNode *RightSibling;

@property (strong, nonatomic) NSMutableArray *memberListArray;
@property (strong, nonatomic) NSMutableArray *imageMapArray;

@property (strong, nonatomic) NSMutableArray *imageIndexArray;
@property (strong, nonatomic) NSString *DEPT_NAME;
@property (nonatomic) int PARENT_DEPT_CD;
@property (nonatomic) int DEPT_CD;
@property (nonatomic) int TREE_LEVEL;
@property (nonatomic) BOOL IS_LAST_SIBLING;

@end
