//
//  MemberViewController.h
//  opentok
//
//  Created by Openit on 2016. 4. 6..
//  Copyright © 2016년 openit. All rights reserved.
//

#import <MessageUI/MessageUI.h>

#import "TreeManager.h"

@interface MemberViewController : BaseViewController <UITextFieldDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate> {
    IBOutlet UIView *mMemberView;
    IBOutlet UITableView *mMemberTableView;
    IBOutlet UITextField *searchTextField;
    
    IBOutlet UIView *mStructView;
    IBOutlet UITableView *mTreeTableView;
    
    //임직원 정보 Data 저장 Array
    NSMutableArray *memberListArray;
    NSMutableArray *searchListArray;
    NSMutableArray *nameArray;
    
    //조직원구성도 Data 저장 Array
    NSMutableArray *deptListArray;
    NSMutableArray *deptMemListArray;
    
    BOOL isSearching;
    BOOL isFirst;
    
    TreeManager *treeManager;
}

- (IBAction)searchBtnClicked:(id)sender;
- (IBAction)searchTextFieldChanged:(id)sender;

- (void)sendSmsEventAction:(NSNumber *)cellindex;
- (void)sendWhisperEventAction:(NSNumber *)cellindex;
- (void)sendEmailEventAction:(NSNumber *)cellindex;
- (void)callPhoneNumEventAction:(NSNumber *)cellindex;

@end
