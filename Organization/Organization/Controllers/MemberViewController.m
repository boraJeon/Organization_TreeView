//
//  MemberViewController.m
//  opentok
//
//  Created by Openit on 2016. 4. 6..
//  Copyright © 2016년 openit. All rights reserved.
//

#import "MemberViewController.h"

#import "MemberTableViewCell.h"
#import "MemberDetailViewController.h"
#import "WhisperChatViewController.h"

#import "TreeNode.h"
#import "MemberInfo.h"

#define ORIGIN_IMG_X 12.f
#define CELL_HEIGHT 40.f

@implementation MemberViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setHiddenBackButton:YES];
    [self setHiddenMenuButton:NO];
    [self setHiddenProfileButton:NO];
    
    [self resizeTopFrameWithString:NSLocalizedString(@"MemberInfo", nil) withImgName:@"ico_myinfo.png"];
    [self setTopImage:@"img_navigation_document.png"];
    
    menuArray = [[NSArray alloc] initWithObjects:NSLocalizedString(@"MemberInfo", nil), NSLocalizedString(@"OrganizationStructure", nil), nil];
    [self makeSubTitleMenuView:self];
    [self setEnableTopImageTouchEvnet:YES];
    
    mTreeTableView.contentInset = UIEdgeInsetsMake(-20, 0, 0, 0);
    mMemberTableView.contentInset = UIEdgeInsetsMake(-20, 0, 0, 0);
    
    memberListArray = [[NSMutableArray alloc] init];
    searchListArray = [[NSMutableArray alloc] init];
    nameArray = [[NSMutableArray alloc] init];
    
    deptMemListArray = [[NSMutableArray alloc] init];
    deptListArray = [[NSMutableArray alloc] init];
    
    isSearching = NO;
    isFirst = YES;
    
    treeManager = [[TreeManager alloc] init];
    [self requestMemberList];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [APP_DELEGATE.mmdrawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeAll];
    [APP_DELEGATE.mmdrawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [APP_DELEGATE.mmdrawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
    [APP_DELEGATE.mmdrawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeNone];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)requestMemberList {
    NSMutableDictionary *param = [[NSMutableDictionary alloc]init];
    [param setObject:@"M" forKey:SERVER_PARAM_MEMBER_TYPE];
    
    [OpenitAPI requestWithName:SERVER_API_MEMBER_LIST
                withParameters:param
                 responseBlock:^(BOOL success, NSDictionary *dict) {
                     if(success){
                         memberListArray = [[dict valueForKey:@"memberList"] mutableCopy];
                         searchListArray = [memberListArray mutableCopy];
                         
                         for (int i = 0; i < [memberListArray count]; i++) {
                             [nameArray addObject:[[memberListArray objectAtIndex:i] valueForKey:@"KOR_NAME"]];
                         }
                         [mMemberTableView reloadData];
                     } else {
                         if([dict valueForKey:@"message"]){
                             [Utils showAlert:self title:NSLocalizedString(@"Notify", nil) message:[dict valueForKey:@"message"] addActions:nil];
                         } else {
                             [Utils showAlert:self title:NSLocalizedString(@"Notify", nil) message:NSLocalizedString(@"NetworkError", nil) addActions:nil];
                         }
                     }
                 }];
}

- (void)requestOrganizationList {
    NSMutableDictionary *param = [[NSMutableDictionary alloc]init];
    [param setObject:@"M" forKey:SERVER_PARAM_MEMBER_TYPE];
    
    [OpenitAPI requestWithName:SERVER_API_MEMBER_ORGANIZATION_LIST
                withParameters:param
                 responseBlock:^(BOOL success, NSDictionary *dict) {
                     if(success){
                         deptListArray = [[dict valueForKey:@"deptList"] mutableCopy];
                         deptMemListArray = [[dict valueForKey:@"memberList"] mutableCopy];
                         
                         treeManager.deptList = deptListArray;
                         treeManager.memberList = deptMemListArray;
                         [treeManager CreateOrgTree:deptListArray];

                         if (treeManager.rootNode != nil)
                             [treeManager PrintTree:treeManager.rootNode];
                         
                         [mTreeTableView reloadData];
                     } else {
                         if([dict valueForKey:@"message"]){
                             [Utils showAlert:self title:NSLocalizedString(@"Notify", nil) message:[dict valueForKey:@"message"] addActions:nil];
                         } else {
                             [Utils showAlert:self title:NSLocalizedString(@"Notify", nil) message:NSLocalizedString(@"NetworkError", nil) addActions:nil];
                         }
                     }
                 }];
}

#pragma mark - TEXTFIELD DELEGATE
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    return YES;
}

#pragma mark - TABLEVIEW DELEGATE & DATASOURC
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (tableView == mTreeTableView) {
        TreeNode *node = [treeManager.totalDataList objectAtIndex:section];
        
        UIView *frontView = [[UIView alloc] init];
        [frontView setBackgroundColor:[UIColor whiteColor]];
        
        CGRect imgFrame = CGRectMake(ORIGIN_IMG_X, -8.f, 13.f, CELL_HEIGHT);
        for (int i = 0; i < [node.imageIndexArray count]; i++) {
            if (node == treeManager.rootNode) {
                break;
            }
            
            NSString *iconImgName = @"";
            if ([[node.imageIndexArray objectAtIndex:i] intValue] == 0) {
                iconImgName = @"img_landline_t.png";
            } else if ([[node.imageIndexArray objectAtIndex:i] intValue] == 1) {
                iconImgName = @"img_landline_a.png";
            } else if ([[node.imageIndexArray objectAtIndex:i] intValue] == 2) {
                iconImgName = @"img_landline_m.png";
            } else if ([[node.imageIndexArray objectAtIndex:i] intValue] == 3) {
                iconImgName = @"img_landline_s.png";
            }
            
            imgFrame.origin.x = i*imgFrame.size.width + ORIGIN_IMG_X;
            UIImageView *imgView = [[UIImageView alloc] initWithFrame:imgFrame];
            [imgView setImage:[UIImage imageNamed:iconImgName]];
            [frontView addSubview:imgView];
        }
        
        imgFrame.origin.x = [node.imageIndexArray count]*imgFrame.size.width + ORIGIN_IMG_X;
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:imgFrame];
        [imgView setImage:[UIImage imageNamed:@"ico_open.png"]];
        [frontView addSubview:imgView];
        
        CGRect labelFrame = imgFrame;
        UILabel *sectionLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelFrame.origin.x + labelFrame.size.width + 8.f, -8.f, 150.f, CELL_HEIGHT)];
        [sectionLabel setText:node.DEPT_NAME];
        [frontView addSubview:sectionLabel];
        
        return frontView;
    }
    else {
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectZero];
        return headerView;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == mTreeTableView) {
        return [treeManager.totalDataList count];
    }
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(tableView == menuTableView) {
        return [menuArray count];
    }
    else if (tableView == mMemberTableView) {
        return [searchListArray count];
    }
    else if (tableView == mTreeTableView) {
        TreeNode *node = [treeManager.totalDataList objectAtIndex:section];
        return [node.memberListArray count];
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(tableView == menuTableView) {
        NSString *cellIdentifier = @"CellIdentifier";
        
        UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        
        [cell.textLabel setText:[menuArray objectAtIndex:indexPath.row]];
        
        return cell;
    } else if (tableView == mMemberTableView) {
        NSString *cellIdentifier = @"membercell";
        
        MemberTableViewCell *cell = (MemberTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[MemberTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        
        cell.parentViewId = self;
        cell.selfIndex = (int)indexPath.row;
        
        [cell.nameLabel setText:[[searchListArray objectAtIndex:indexPath.row] valueForKey:@"KOR_NAME"]];
        [cell.deptLabel setText:[[searchListArray objectAtIndex:indexPath.row] valueForKey:@"DEPT_NAME"]];
        
        if ([[searchListArray objectAtIndex:indexPath.row] valueForKey:@"photoThumbUrl"] != nil) {
            NSString *userPicDownloadUrl = [[Utils getWebUrl] stringByAppendingString:[[searchListArray objectAtIndex:indexPath.row] valueForKey:@"photoThumbUrl"]];
            NSData *imageData = [APP_DELEGATE.mImageCashArray valueForKey:[Utils convertUrlToDB:userPicDownloadUrl]];
            
            if(imageData == nil){
                imageData = [DataBaseManager getImageData:userPicDownloadUrl];
            }
            
            if(imageData == nil){
                imageData = [[NSData alloc] initWithContentsOfURL:[[NSURL alloc] initWithString:userPicDownloadUrl]];
                [DataBaseManager insertImageData:userPicDownloadUrl imageData:imageData];
            } else {
                NSString *encodeUrl = [Utils convertUrlToDB:userPicDownloadUrl];
                [APP_DELEGATE.mImageCashArray setObject:imageData forKey:encodeUrl];
            }
            [cell.profileImg setImage:[UIImage imageWithData:imageData]];
        }
        
        return cell;
    } else if(tableView == mTreeTableView) {
        NSString *cellIdentifier = @"OrganizationIdentifier";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        for (UIView *temp in cell.contentView.subviews) {
            if (temp.tag == 100) {
                [temp removeFromSuperview];
                break;
            }
        }

        TreeNode *node = [treeManager.totalDataList objectAtIndex:indexPath.section];
        MemberInfo *memberInfo = [node.memberListArray objectAtIndex:indexPath.row];

        UIView *frontView = [[UIView alloc] initWithFrame:cell.contentView.frame];
        [frontView setBackgroundColor:[UIColor clearColor]];
        [frontView setTag:100];

        CGRect imgFrame = CGRectMake(ORIGIN_IMG_X, 0.f, 13.f, CELL_HEIGHT);
        for (int i = 0; i < [memberInfo.imageIndexArray count]; i++) {
            NSString *iconImgName = @"";
            if ([[memberInfo.imageIndexArray objectAtIndex:i] intValue] == 0) {
                iconImgName = @"img_landline_t.png";
            } else if ([[memberInfo.imageIndexArray objectAtIndex:i] intValue] == 1) {
                iconImgName = @"img_landline_a.png";
            } else if ([[memberInfo.imageIndexArray objectAtIndex:i] intValue] == 2) {
                iconImgName = @"img_landline_m.png";
            } else if ([[memberInfo.imageIndexArray objectAtIndex:i] intValue] == 3) {
                iconImgName = @"img_landline_s.png";
            }
            
            imgFrame.origin.x = i*imgFrame.size.width + ORIGIN_IMG_X;
            UIImageView *imgView = [[UIImageView alloc] initWithFrame:imgFrame];
            [imgView setImage:[UIImage imageNamed:iconImgName]];
            [frontView addSubview:imgView];
        }
        
        double imgSize = 14.5f;
        CGRect labelFrame = imgFrame;

        UIImageView *personImg = [[UIImageView alloc] initWithFrame:CGRectMake(labelFrame.origin.x + labelFrame.size.width + 8.f, 14.f, imgSize, imgSize)];
        [personImg setImage:[UIImage imageNamed:@"ico_employer.png"]];
        [frontView addSubview:personImg];

        UILabel *sectionLabel = [[UILabel alloc] initWithFrame:CGRectMake(personImg.frame.origin.x + personImg.frame.size.width + 8.f, 0.f, 150.f, CELL_HEIGHT)];
        [sectionLabel setText:memberInfo.KOR_NAME];
        [frontView addSubview:sectionLabel];
        
        [cell.contentView addSubview:frontView];

        return cell;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [searchTextField resignFirstResponder];
    
    if (tableView == menuTableView) {
        [self topImageTouchEvent];
        if (indexPath.row == 0) {
            [mMemberView setHidden:NO];
            [mStructView setHidden:YES];
            [self resizeTopFrameWithString:[menuArray objectAtIndex:indexPath.row] withImgName:@"ico_myinfo.png"];
        }
        else if (indexPath.row == 1) {
            [mMemberView setHidden:YES];
            [mStructView setHidden:NO];
            [self resizeTopFrameWithString:[menuArray objectAtIndex:indexPath.row] withImgName:@"ico_dept_list.png"];
            
            if (isFirst) {
                isFirst = NO;
                [self requestOrganizationList];
            }
        }
    }
    else if (tableView == mMemberTableView) {
        MemberDetailViewController *memberDetailVC = [[Utils getCurrScreenStoryBoard] instantiateViewControllerWithIdentifier:@"memberdetailVC"];
        [memberDetailVC setMemberSeq:[[searchListArray objectAtIndex:indexPath.row] valueForKey:@"MEMBER_SEQ"]];
        [self.navigationController pushViewController:memberDetailVC animated:YES];
    }
    else if (tableView == mTreeTableView) {
        TreeNode *node = [treeManager.totalDataList objectAtIndex:indexPath.section];
        MemberInfo *memberInfo = [node.memberListArray objectAtIndex:indexPath.row];
    
        if (memberInfo == nil) {
            return;
        }
        
        MemberDetailViewController *memberDetailVC = [[Utils getCurrScreenStoryBoard] instantiateViewControllerWithIdentifier:@"memberdetailVC"];
        [memberDetailVC setMemberSeq:[NSString stringWithFormat:@"%d", memberInfo.MEMBER_SEQ]];
        [self.navigationController pushViewController:memberDetailVC animated:YES];
    }
}

#pragma mark - IBAction
- (void)menuButtonClicked:(UIButton *)btn {
    [APP_DELEGATE.mmdrawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

- (void)profileButtonClicked:(UIButton *)btn {
    [APP_DELEGATE.mmdrawerController toggleDrawerSide:MMDrawerSideRight animated:YES completion:nil];
}

- (IBAction)searchBtnClicked:(id)sender {
    [self searchTextFieldChanged:searchTextField];
}

- (IBAction)searchTextFieldChanged:(id)sender {
    UITextField *field = (UITextField *)sender;
    
    [searchListArray removeAllObjects];
    NSPredicate *resultPredicate = [NSPredicate
                                    predicateWithFormat:@"SELF contains[cd] %@",
                                    field.text];
    
    NSArray *searchArr = [nameArray filteredArrayUsingPredicate:resultPredicate];
    
    for(NSString *nameStr in searchArr) {
        for (int i = 0; i < [memberListArray count]; i++) {
            if ([[[memberListArray objectAtIndex:i] valueForKey:@"KOR_NAME"] isEqualToString:nameStr]) {
                [searchListArray addObject:[memberListArray objectAtIndex:i]];
            }
        }
    }
    
    if([field.text isEqualToString:@""])
        searchListArray = [memberListArray mutableCopy];
    
    [mMemberTableView reloadData];
}

- (void)sendSmsEventAction:(NSNumber *)cellindex {
    int indexRow = [cellindex intValue];
    NSString *telStr = [[searchListArray objectAtIndex:indexRow] valueForKey:@"TEL_MOBILE"];
    
    if (telStr != nil) {
        NSArray *toRecipents = [NSArray arrayWithObject:telStr];
        
        MFMessageComposeViewController *mc = [[MFMessageComposeViewController alloc] init];
        mc.messageComposeDelegate = self;
        [mc setRecipients:toRecipents];
        
        if ([MFMessageComposeViewController canSendText]) {
            [self presentViewController:mc animated:YES completion:nil];
        } else {
            [Utils showAlert:self title:NSLocalizedString(@"Notify", nil) message:NSLocalizedString(@"DonotSendSmsThisDevice", nil) addActions:nil];
        }
    }
    else {
        [Utils showAlert:self title:NSLocalizedString(@"Notify", nil) message:NSLocalizedString(@"NotExistPhoneNumber", nil) addActions:nil];
    }
}

- (void)sendWhisperEventAction:(NSNumber *)cellindex {
    int indexRow = [cellindex intValue];
    NSString *memberSeq = [[searchListArray objectAtIndex:indexRow] valueForKey:@"MEMBER_SEQ"];
    
    if ([memberSeq intValue] == [DataBaseManager getUserInfo].memberSeq.intValue) {
        [Utils showAlert:self title:NSLocalizedString(@"Notify", nil) message:NSLocalizedString(@"DisableWhisperwithMyself", nil) addActions:nil];
        return;
    }
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc]init];
    [param setObject:[NSNumber numberWithInt:[memberSeq intValue]] forKey:SERVER_PARAM_MEMBER_SEQ];
    
    [OpenitAPI requestWithName:SERVER_API_CHAT_ROOM_DETAIL
                withParameters:param
                 responseBlock:^(BOOL success, NSDictionary *dict) {
                     if(success){
                         WhisperChatViewController *whisperchatVC = [[Utils getCurrScreenStoryBoard] instantiateViewControllerWithIdentifier:@"whisperchatVC"];
                         whisperchatVC.roomSeq = [dict valueForKey:@"roomSeq"];
                         whisperchatVC.targetMemberSeq = memberSeq;
                         [self.navigationController pushViewController:whisperchatVC animated:YES];
                     } else {
                         if([dict valueForKey:@"message"]){
                             [Utils showAlert:self title:NSLocalizedString(@"Notify", nil) message:[dict valueForKey:@"message"] addActions:nil];
                         } else {
                             [Utils showAlert:self title:NSLocalizedString(@"Notify", nil) message:NSLocalizedString(@"NetworkError", nil) addActions:nil];
                         }
                     }
                 }];
}

- (void)sendEmailEventAction:(NSNumber *)cellindex {
    int indexRow = [cellindex intValue];
    NSString *emailStr = [[searchListArray objectAtIndex:indexRow] valueForKey:@"MEMBER_EMAIL"];
    
    if (emailStr != nil) {
        NSArray *toRecipents = [NSArray arrayWithObject:emailStr];
        
        MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
        mc.mailComposeDelegate = self;
        [mc setSubject:@""];
        [mc setMessageBody:@"" isHTML:NO];
        [mc setToRecipients:toRecipents];
        
        if ([MFMailComposeViewController canSendMail]) {
            [self presentViewController:mc animated:YES completion:nil];
        }
        else {
            [Utils showAlert:self title:NSLocalizedString(@"Notify", nil) message:NSLocalizedString(@"DonotSendEmailThisDevice", nil) addActions:nil];
        }
    }
    else {
        [Utils showAlert:self title:NSLocalizedString(@"Notify", nil) message:NSLocalizedString(@"NotExistEmailAddress", nil) addActions:nil];
    }
}

- (void)callPhoneNumEventAction:(NSNumber *)cellindex {
    int indexRow = [cellindex intValue];
    
    NSString *telStr = [[searchListArray objectAtIndex:indexRow] valueForKey:@"TEL_MOBILE"];
    
    [Utils callWithTelNumber:telStr];
}

#pragma mark - Email Delgate & SMS Delegate
- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent: {
            NSLog(@"Mail sent");
            [Utils showAlert:self title:NSLocalizedString(@"Notify", nil) message:NSLocalizedString(@"EmailSendSuccess", nil) addActions:nil];
        }
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    switch (result)
    {
        case MessageComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MessageComposeResultSent: {
            NSLog(@"Mail sent");
            [Utils showAlert:self title:NSLocalizedString(@"Notify", nil) message:NSLocalizedString(@"SmsSendSuccess", nil) addActions:nil];
        }
            break;
        case MessageComposeResultFailed:
            NSLog(@" Faild ");
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
