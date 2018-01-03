//
//  TreeManager.m
//  opentok
//
//  Created by Openit on 2016. 6. 22..
//  Copyright © 2016년 openit. All rights reserved.
//

#import "TreeManager.h"
#import "MemberInfo.h"

@implementation TreeManager

@synthesize rootNode;
@synthesize nodeList;
@synthesize deptList;
@synthesize memberList;
@synthesize tempParentList;
@synthesize totalDataList;

-(id)init {
    self = [super init];
    if (self) {
        nodeList = [[NSMutableArray alloc] init];
        deptList = [[NSMutableArray alloc] init];
        memberList = [[NSMutableArray alloc] init];
        tempParentList = [[NSMutableArray alloc] init];
        
        totalDataList = [[NSMutableArray alloc] init];
        
        rootNode = nil;
    }
    return self;
}

-(void)CreateOrgTree:(NSMutableArray *)deptlist
{
    for(int i = 0; i < [deptlist count]; i++)
    {
        if ([[deptlist[i] valueForKey:@"PARENT_DEPT_CD"] intValue] == 0)
        {
            TreeNode *treeNode = [[TreeNode alloc] init];
            treeNode.DEPT_NAME = [deptlist[i] valueForKey:@"DEPT_NAME"];
            treeNode.IS_LAST_SIBLING = YES;
            treeNode.PARENT_DEPT_CD = [[deptlist[i] valueForKey:@"PARENT_DEPT_CD"] intValue];
            treeNode.DEPT_CD = [[deptlist[i] valueForKey:@"DEPT_CD"] intValue];
            treeNode.TREE_LEVEL = 0;
            
            rootNode = treeNode;
            [nodeList addObject:treeNode];
            
            [tempParentList addObject:treeNode];
            [self CreateOrgTreeChild:tempParentList];
        }
    }
}

-(void)CreateOrgTreeChild:(NSMutableArray *)parentList
{
    for(int i = 0;i < [parentList count]; i++)
    {
        NSMutableArray *tempList = [[NSMutableArray alloc] init];
        TreeNode *parentNode = parentList[i];
        for(int j = 0; j < [deptList count]; j++)
        {
//            if(DeptList[j].TREE_DONE == false)
//            {
                if ([[deptList[j] valueForKey:@"PARENT_DEPT_CD"] intValue] == parentNode.DEPT_CD)
                {
                    TreeNode *treeNode = [[TreeNode alloc] init];
                    treeNode.DEPT_NAME = [deptList[j] valueForKey:@"DEPT_NAME"];
                    treeNode.IS_LAST_SIBLING = NO;
                    treeNode.PARENT_DEPT_CD = [[deptList[j] valueForKey:@"PARENT_DEPT_CD"] intValue];
                    treeNode.DEPT_CD = [[deptList[j] valueForKey:@"DEPT_CD"] intValue];
                    treeNode.TREE_LEVEL = 0;
                    
                    for(int x = 0;x < [memberList count];x++)
                    {
                        NSDictionary *dict = [memberList objectAtIndex:x];
                        if (treeNode.DEPT_CD == [[dict valueForKey:@"DEPT_CD"] intValue]) {
                            MemberInfo *memberInfo = [[MemberInfo alloc] init];
                            
                            memberInfo.DEPT_CD = [[dict valueForKey:@"DEPT_CD"] intValue];
                            memberInfo.MEMBER_SEQ = [[dict valueForKey:@"MEMBER_SEQ"] intValue];
                            memberInfo.POSITION_CD = [[dict valueForKey:@"POSITION_CD"] intValue];
                            memberInfo.POSITION_ORDER = [[dict valueForKey:@"POSITION_ORDER"] intValue];
                            memberInfo.KOR_NAME = [dict valueForKey:@"KOR_NAME"];
                            memberInfo.POSITION_NAME = [dict valueForKey:@"POSITION_NAME"];
                            
                            memberInfo.IS_LAST = NO;
                            
                            [treeNode.memberListArray addObject:memberInfo];
                        }
                    }
                    
                    if([treeNode.memberListArray count] > 0)
                    {
                        MemberInfo *lastMember = treeNode.memberListArray[([treeNode.memberListArray count] - 1)];
                        lastMember.IS_LAST = YES;
                    }
                    
                    treeNode.TREE_LEVEL = (parentNode.TREE_LEVEL + 1);
                    
                    for (NSString *flag in parentNode.imageMapArray)
                    {
                        [treeNode.imageMapArray addObject:flag];
                    }
                    
                    [treeNode.imageMapArray addObject:@"1"];
                    
                    [tempList addObject:treeNode];
                    [self AppendNode:parentNode addNode:treeNode];
                }
//            }
        }
        
        if([tempList count] > 0)
        {
            TreeNode *lastNode = tempList[([tempList count]-1)];
            lastNode.IS_LAST_SIBLING = true;
            [lastNode.imageMapArray removeLastObject];
            [lastNode.imageMapArray addObject:@"0"];
        }
        
        [self CreateOrgTreeChild:tempList];
    }
}

-(void) AppendNode:(TreeNode *)parentnode addNode:(TreeNode *)childnode
{
    if (parentnode.LeftChild == NULL )
        parentnode.LeftChild = childnode;
    else
    {
        TreeNode* Curr = parentnode.LeftChild;
        
        while(Curr.RightSibling != NULL)
        {
            Curr = Curr.RightSibling ;
        } 
        Curr.RightSibling = childnode;
    } 
}

-(void) PrintTree:(TreeNode *)node
{
    NSMutableArray *imgList = [[NSMutableArray alloc] init];
    if(node == rootNode)
    {
//        [imgList addObject:[NSNumber numberWithInt:0]];
    }
    else
    {
        for(int i = 0; i < ([node.imageMapArray count] - 1); i++)
        {
            [imgList addObject:[NSNumber numberWithInt:[node.imageMapArray[i] intValue]]];
        }
        
        if(node.IS_LAST_SIBLING)
            [imgList addObject:[NSNumber numberWithInt:2]];
        else
            [imgList addObject:[NSNumber numberWithInt:3]];
    }
    
    node.imageIndexArray = imgList;
    
    [totalDataList addObject:node];
    
    for (MemberInfo *meminfo in node.memberListArray)
    {
        NSMutableArray *memberImgList = [[NSMutableArray alloc] init];
        for(int i = 0; i < [node.imageMapArray count]; i++)
        {
            [memberImgList addObject:[NSNumber numberWithInt:[node.imageMapArray[i] intValue]]];
        }
        
        if(meminfo.IS_LAST)
        {
            if(node.LeftChild == NULL)
            {
                [memberImgList addObject:[NSNumber numberWithInt:2]];
            }
            else
            {
                [memberImgList addObject:[NSNumber numberWithInt:3]];
            }
        }
        else
        {
            [memberImgList addObject:[NSNumber numberWithInt:3]];
        }
        
        meminfo.imageIndexArray = memberImgList;
    }
    
    if (node.LeftChild != NULL) [self PrintTree:node.LeftChild];
    if (node.RightSibling != NULL) [self PrintTree:node.RightSibling];
}


@end
