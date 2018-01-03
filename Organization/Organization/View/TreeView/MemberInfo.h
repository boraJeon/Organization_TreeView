//
//  MemberInfo.h
//  opentok
//
//  Created by Openit on 2016. 6. 22..
//  Copyright © 2016년 openit. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MemberInfo : NSObject

@property (strong, nonatomic) NSMutableArray *imageMapArray;
@property (strong, nonatomic) NSMutableArray *imageIndexArray;

@property (nonatomic, strong) NSString *KOR_NAME;
@property (nonatomic, strong) NSString *POSITION_NAME;
@property (nonatomic) int DEPT_CD;
@property (nonatomic) int POSITION_CD;
@property (nonatomic) int MEMBER_SEQ;
@property (nonatomic) int POSITION_ORDER;

@property (nonatomic) BOOL IS_LAST;

@end
