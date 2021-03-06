//
//  FriendRequestTableViewController.m
//  sandbox
//
//  Created by wuyue on 3/25/14.
//  Copyright (c) 2014 jake. All rights reserved.
//

#import "T2friendRequest.h"
#import <AWSSimpleDB/AWSSimpleDB.h>
#import "AmazonClientManager.h"
#import "FriendList.h"
#import "simpleDBHelper.h"
NSString *USER_NAME;
NSMutableArray *requestList;
NSString* numberToAccept;
NSString* nameToAccept;
NSInteger* rowSelected;
@interface T2friendRequest ()

@end

@implementation T2friendRequest

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    requestList = [[NSMutableArray alloc] init];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    USER_NAME = [defaults objectForKey:@"EAT2GETHER_ACCOUNT_NAME"];
    SimpleDBGetAttributesRequest *gar = [[SimpleDBGetAttributesRequest alloc] initWithDomainName:USER_NAME andItemName:@"friendRequestListItem"];
    SimpleDBGetAttributesResponse *response = [[AmazonClientManager sdb] getAttributes:gar];
    int count = 0;
    for (SimpleDBAttribute *attr in response.attributes ) {
        count++;
        FriendList *myOnlineFriendListelement = [[FriendList alloc]initWithName:attr.value onLineorNot:(YES) number:attr.name];
        if (![myOnlineFriendListelement.phoneNumber isEqualToString:@"2060000000"]) {
            [requestList addObject:myOnlineFriendListelement];
        }
    }
    NSLog(@"requestlist is %lu and  %d", (unsigned long)requestList.count, count);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return requestList.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"friendRequstCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"friendRequstCell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    FriendList *currentFriend = [requestList objectAtIndex:indexPath.row];
    cell.textLabel.text = currentFriend.name;
    rowSelected = (NSInteger *)indexPath.row;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FriendList *currentFriend = [requestList objectAtIndex:indexPath.row];
    numberToAccept = [[NSString alloc] initWithFormat:@"%@",currentFriend.phoneNumber];
    nameToAccept = [[NSString alloc] initWithFormat:@"%@",currentFriend.name];
    NSString* message = [[NSString alloc] initWithFormat:@"Do you want to accept friend request from %@ (%@)?", currentFriend.name,currentFriend.phoneNumber];
    UIAlertView *alert;
    alert = [[UIAlertView alloc] initWithTitle:@"Accept Friend" message:message delegate:self cancelButtonTitle:@"Accept" otherButtonTitles:@"Decline", nil];
    [alert show];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

//if the person accept the friend request
//add each other to the friendListItem
//add each other to the onlineFriendList or offlineFriendList according to onlineItem
//delete from the friendRequestList
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    simpleDBHelper* hp = [[simpleDBHelper alloc] init];
    if (buttonIndex == 0 && [[alertView title] isEqualToString:@"Accept Friend"])
    {
        NSLog(@"button clicked");
        [hp addAtrribute:USER_NAME item:@"friendListItem" attribute:numberToAccept value:nameToAccept];
        NSString* myNickName = [hp getAtrributeValue:USER_NAME item:@"nicknameItem" attribute:@"nicknameAttribute"];
        [hp addAtrribute:numberToAccept item:@"friendListItem" attribute:USER_NAME value:myNickName];
        if([[hp getAtrributeValue:numberToAccept item:@"onlineItem" attribute:@"onlineAttribute"] isEqualToString:@"online"]){
            [hp addAtrribute:USER_NAME item:@"onlineFriendListItem" attribute:numberToAccept value:nameToAccept];
        }else{
            [hp addAtrribute:USER_NAME item:@"offlineFriendListItem" attribute:numberToAccept value:nameToAccept];
        }
        
        if([[hp getAtrributeValue:USER_NAME item:@"onlineItem" attribute:@"onlineAttribute"] isEqualToString:@"online"]){
            [hp addAtrribute:numberToAccept item:@"onlineFriendListItem" attribute:USER_NAME value:myNickName];
        }else{
            [hp addAtrribute:numberToAccept item:@"offlineFriendListItem" attribute:USER_NAME value:myNickName];
        }
        [hp deleteAttributePair:USER_NAME item:@"friendRequestListItem" attributeName:numberToAccept attributeValue:nameToAccept];
        [requestList removeObjectAtIndex:(int)(rowSelected)];
        
    }
    NSLog(@"%@, %@, %@", USER_NAME, numberToAccept, nameToAccept);
    //[hp deleteAtrribute:USER_NAME item:@"friendRequestListItem" attribute:numberToAccept value:nameToAccept];
    [self.tableView reloadData];
}


-(void)backButtonPress:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

@end
