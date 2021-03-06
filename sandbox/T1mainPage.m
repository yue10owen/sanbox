//
//  FriendListTableViewController.m
//  friendlist
//
//  Created by wuyue on 3/24/14.
//  Copyright (c) 2014 wuyue. All rights reserved.
//

#import "T1mainPage.h"
#import "FriendList.h"
#import <AWSSimpleDB/AWSSimpleDB.h>
#import "AmazonClientManager.h"
#import "T1friendPreference.h"
#import "simpleDBHelper.h"
#import "Constants.h"
#import <AWSRuntime/AWSRuntime.h>
NSString *USER_NAME;
NSMutableArray *onlineFriendList;
NSMutableArray *offlineFriendList;
FriendList *currentFriend;

//setup the dispatch//
@interface T1mainPage (){
    dispatch_queue_t queue;
}
@end

@implementation T1mainPage
// set and get the frindlist
@synthesize FriendListelements = _FriendListelements;
@synthesize s3 = _s3;
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        [self.tableView registerClass:[UITableViewCell class]
               forCellReuseIdentifier:@"Available Friends"];
        self.refreshControl = [[UIRefreshControl alloc] init];
        self.refreshControl = self.refreshControl;
        [self.refreshControl addTarget:self
                                action:@selector(handleRefresh:)
                      forControlEvents:UIControlEventValueChanged];
    }
    return self;
}


- (void)viewDidAppear:(BOOL)animated{
    NSLog(@"Tabs showed up!");
    [self.view setUserInteractionEnabled:NO];
    self.tabBarController.tabBar.userInteractionEnabled = NO;
    [loadingAnimation showHUDAddedTo:self.view animated:YES];
    [self loadFriends];
    [self loadFriends];
    [self loadFriends];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"Tabs showed up!");
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    USER_NAME = [defaults objectForKey:@"EAT2GETHER_ACCOUNT_NAME"];
    
    self.s3 = [[AmazonS3Client alloc] initWithAccessKey:ACCESS_KEY_ID withSecretKey:SECRET_KEY];
    self.s3.endpoint = [AmazonEndpoints s3Endpoint:US_WEST_2];
    [self.tableView reloadData];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"LOGGED_IN"];
    [self.refreshControl addTarget:self action:@selector(handleRefresh:) forControlEvents:UIControlEventValueChanged];
    /*
     FriendList *myOnlineFriendListelement = [[FriendList alloc]initWithName:@"My first online friend" onLineorNot:(YES)];
     [self.FriendListelements addObject:myOnlineFriendListelement];
     
     FriendList *myOfflineFriendListelement = [[FriendList alloc]initWithName:@"My first Offline friend" onLineorNot:(NO)];
     [self.FriendListelements addObject:myOfflineFriendListelement];
     */
    // reload the data
    
    [self loadFriends];
    [self loadFriends];
}
- (void)viewDidDisappear:(BOOL)animated{
    [self loadFriends];
    [onlineFriendList removeAllObjects];
    [offlineFriendList removeAllObjects];
}


- (void)loadFriends{
    queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
    //*************************************//
    //load all the online friend
    SimpleDBGetAttributesRequest *gar = [[SimpleDBGetAttributesRequest alloc] initWithDomainName:USER_NAME andItemName:@"onlineFriendListItem"];
    SimpleDBGetAttributesResponse *response = [[AmazonClientManager sdb] getAttributes:gar];
    if(response.error != nil)
    {
        NSLog(@"Error: %@", response.error);
    }
    if (onlineFriendList == nil) {
        onlineFriendList = [[NSMutableArray alloc] initWithCapacity:[response.attributes count]];
    }
    else {
        [onlineFriendList removeAllObjects];
    }
    simpleDBHelper *hp = [[simpleDBHelper alloc]init];
        int numberOfOnlineFriends = 0;
    for (SimpleDBAttribute *attr in response.attributes) {
        if (![attr.name isEqualToString:@"2060000000"]) {
            NSString *startTime = [hp getAtrributeValue:attr.name item:@"availbilityItem" attribute:@"startTimeAttribute"];
            NSString *endTime = [hp getAtrributeValue:attr.name item:@"availbilityItem" attribute:@"endTimeAttribute"];
            FriendList *myOnlineFriendListelement = [[FriendList alloc]initWithName:attr.value onLineorNot:(YES) number:attr.name start:startTime end:endTime];
            numberOfOnlineFriends++;
            // DON'T DELETE!!!!!!!!!!!!!!!!!!!!
            /*
            if (onlineFriendList.count > 0) {
                for (int i = 0; i<onlineFriendList.count; i++) {
                    FriendList *local = [onlineFriendList objectAtIndex:i];
                    if (local.startTime.length > 8 && myOnlineFriendListelement.startTime.length > 8) {
                        NSDateFormatter *df = [[NSDateFormatter alloc] init];
                        [df setDateFormat:@"EEE,MM/dd hh:mm a"];
                        for (int j = 0; j< onlineFriendList.count
                             ; j++) {
                            NSDate *localDate = [[NSDate alloc]init];
                            localDate = [df dateFromString:local.startTime];
                            NSDate *newDate = [[NSDate alloc]init];
                            newDate = [df dateFromString:myOnlineFriendListelement.startTime];
                            if ([localDate compare:newDate] == NSOrderedDescending) {
                                [onlineFriendList insertObject:myOnlineFriendListelement atIndex:j];
                            }
                            break;
                        }
                        [onlineFriendList addObject:myOnlineFriendListelement];
                        
                    }else{
                        [onlineFriendList insertObject:myOnlineFriendListelement atIndex:0];
                    }
                }*/
            //}else{
                [onlineFriendList addObject:myOnlineFriendListelement];
            //}
        }
        
    }
    
    [self.tableView reloadData];
    //load all the offline friend
    SimpleDBGetAttributesRequest *gar2 = [[SimpleDBGetAttributesRequest alloc] initWithDomainName:USER_NAME andItemName:@"offlineFriendListItem"];
    SimpleDBGetAttributesResponse *response2 = [[AmazonClientManager sdb] getAttributes:gar2];
    if(response2.error != nil)
    {
        NSLog(@"Error: %@", response2.error);
    }
    if (offlineFriendList == nil) {
        offlineFriendList = [[NSMutableArray alloc] initWithCapacity:[response2.attributes count]];
    }
    else {
        [offlineFriendList removeAllObjects];
    }
    int numberOfOfflineFriends = 0;
        
    for (SimpleDBAttribute *attr in response2.attributes) {
        FriendList *myOfflineFriendListelement = [[FriendList alloc]initWithName:attr.value onLineorNot:(NO) number:attr.name];
        if (![myOfflineFriendListelement.phoneNumber isEqualToString:@"2060000000"]) {
            [offlineFriendList addObject:myOfflineFriendListelement];
            numberOfOfflineFriends++;
        }
        
    }
        
    //self checking mode
    NSMutableArray *allFrindsNumber = [hp getAllAttributeNames:USER_NAME item:@"friendListItem"];
    if (numberOfOnlineFriends + numberOfOfflineFriends < allFrindsNumber.count - 1) {
            //self checking mode is enabled.
        
        NSMutableArray *onlineFriendsNumber = [[NSMutableArray alloc]init];
        for (FriendList *element in onlineFriendList) {
            [onlineFriendsNumber addObject:element.phoneNumber];
        }
        
        NSMutableArray *offlineFriendsNumber = [[NSMutableArray alloc]init];
        for (FriendList *element in offlineFriendList) {
            [offlineFriendsNumber addObject:element.phoneNumber];
        }
        
        for(int i = 0; i < allFrindsNumber.count; i++){
            NSString *friendNumber = allFrindsNumber[i];
            if ((![onlineFriendsNumber containsObject:friendNumber]) &&
                !([offlineFriendsNumber containsObject:friendNumber])) {
                if ([friendNumber isEqualToString:@"2060000000"]) {
                    break;
                }
                NSString *onlineOrNot = [hp getAtrributeValue:friendNumber item:@"onlineItem" attribute:@"onlineAttribute"];
                BOOL status = [onlineOrNot isEqualToString:@"online"];
                NSString *startTime = [hp getAtrributeValue:friendNumber item:@"availbilityItem" attribute:@"startTimeAttribute"];
                NSString *endTime = [hp getAtrributeValue:friendNumber item:@"availbilityItem" attribute:@"endTimeAttribute"];
                NSString *nickName = [hp getAtrributeValue:friendNumber item:@"nicknameItem" attribute:@"nicknameAttribute"];
                if (status) {
                    FriendList *myOnlineFriendListelement = [[FriendList alloc]initWithName:nickName onLineorNot:(YES) number:friendNumber start:startTime end:endTime];
                    [onlineFriendList addObject:myOnlineFriendListelement];
                    [hp addAtrribute:USER_NAME item:@"onlineFriendListItem" attribute:friendNumber value:nickName];
                }else{
                    FriendList *myOnlineFriendListelement = [[FriendList alloc]initWithName:nickName onLineorNot:(NO) number:friendNumber start:startTime end:endTime];
                    [offlineFriendList addObject:myOnlineFriendListelement];
                    [hp addAtrribute:USER_NAME item:@"offlineFriendListItem" attribute:friendNumber value:nickName];
                }
            }
        }
    }
    dispatch_async(dispatch_get_main_queue(),^{
    //add all of them to the table view
            self.FriendListelements =[[NSMutableArray alloc]init];
            [self.FriendListelements addObjectsFromArray:(onlineFriendList)];
            [self.FriendListelements addObjectsFromArray:(offlineFriendList)];
            [self.tableView reloadData];
            //Call the method to hide the Indicator after 3 seconds
            [self performSelector:@selector(stopRKLoading) withObject:nil];
        });
        
    });
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    // Return the number of sections. always in one section
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0){
        return onlineFriendList.count;
    }else{
        return offlineFriendList.count;
    }
}

// we can refer certain view
// index path a list of numbers what row we looking at
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    simpleDBHelper *hp = [[simpleDBHelper alloc]init];
    static NSString *OnLineCellIndetifier = @"Available Friends";  // what type of cell  to actuall indentify use that in story board
    static NSString *OffLineCellIndetifier = @"UnAvailable Friends";
    // which friend we point at
    NSString *cellIdentifier = currentFriend.onLineorNot ? OnLineCellIndetifier : OffLineCellIndetifier;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if( indexPath.section == 0 ){
        currentFriend = [onlineFriendList objectAtIndex:indexPath.row];  // which cell we looking at
    }else{
        currentFriend = [offlineFriendList objectAtIndex:indexPath.row];  // which cell we looking at
    }
    // if you have extra give it to me
    if (cell==nil){
        if( indexPath.section == 0 ){
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
            NSMutableString *label = [[NSMutableString alloc]initWithFormat:@"%@",currentFriend.startTime];
            [label appendFormat:@"\n to \n"];
            [label appendFormat:@"%@",currentFriend.endTime];
            cell.detailTextLabel.text = label;
            cell.detailTextLabel.font = [UIFont systemFontOfSize:12.0];
            cell.detailTextLabel.numberOfLines = 3;
        }else{
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
    }else{
        if (indexPath.section == 0) {
            NSMutableString *label = [[NSMutableString alloc]initWithFormat:@"%@",currentFriend.startTime];
            [label appendFormat:@"\n to \n"];
            [label appendFormat:@"%@",currentFriend.endTime];
            cell.detailTextLabel.text = label;
            cell.detailTextLabel.font = [UIFont systemFontOfSize:12.0];
            cell.detailTextLabel.numberOfLines = 3;
        }

    }
    
//    NSString *currentphonenumber = currentFriend.phoneNumber;
  
    
    // Configure the cell...
    // nnnnnnnnnnnnnnnneeeeeeeeedddddddddhelp/////    get the photo from the s3   should be same as T3mepage
    // load the image on the s3
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        // Set the content type so that the browser will treat the URL as an image.
        
        /*S3ResponseHeaderOverrides *override = [[S3ResponseHeaderOverrides alloc] init];
        override.contentType = @"image/jpeg";
        
        // Request a pre-signed URL to picture that has been uplaoded.
        S3GetPreSignedURLRequest *gpsur = [[S3GetPreSignedURLRequest alloc] init];
        gpsur.key                     = currentFriend.phoneNumber;
        gpsur.bucket                  = [Constants pictureBucket];
        gpsur.expires                 = [NSDate dateWithTimeIntervalSinceNow:(NSTimeInterval) 3600]; // Added an hour's worth of seconds to the current time.
        gpsur.responseHeaderOverrides = override;
        // Get the URL
        NSError *error = nil;
        NSURL *url = [self.s3 getPreSignedURL:gpsur error:&error];
         */
        
        
        
        NSString *geturl= [hp getAtrributeValue:currentFriend.phoneNumber item:@"photoUrlItem" attribute:@"photoUrlAttribute"];
        
        NSLog(@"da chu shenme lai le ne%@",geturl);
        NSURL *url = [NSURL URLWithString:geturl];
        
        NSData *data = [NSData dataWithContentsOfURL: url];
        UIImage *image = [UIImage imageWithData:data];
        NSError *error = nil;
        //      NSString *simpleDBURL = [url absoluteString];
        // try to put the url to simpledb
        // simpleDBHelper *hp = [[simpleDBHelper alloc]init];
        //  [hp updateAtrribute:USER_NAME item:@"photoProfileItem" attribute:@"photoAttribute" newValue:simpleDBURL];
        if(url == nil){
            NSLog(@"Errorhmgfjhgfjhgf: %@", error);
            if(error != nil){
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"Error: %@", error);
                });
            }else{
                NSLog(@"the profile pic is missing");
            }
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                CGSize itemSize = CGSizeMake(40, 40);
                UIGraphicsBeginImageContext(itemSize);
                CGRect imageRect = CGRectMake(0.0, 0.3, itemSize.width, itemSize.height);
               
                [image drawInRect:imageRect];
                cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                
                NSLog(@"get here?");
                
            });
        }
    });
    cell.textLabel.text = currentFriend.name;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    currentFriend = [self.FriendListelements objectAtIndex:indexPath.row];
    if (currentFriend.onLineorNot) {
        [self performSegueWithIdentifier:@"onlineFriendClicked" sender:self];
    }else{
        [self performSegueWithIdentifier:@"offlineFriendClicked" sender:self];
    }
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    T1friendPreference *prefer = (T1friendPreference *)[[segue destinationViewController] topViewController];
    NSLog(@"second, %@", currentFriend.name);
    prefer.friendPhoneNumber = currentFriend.phoneNumber;
    prefer.friendNickName = currentFriend.name;
    if([segue.identifier isEqualToString:@"onlineFriendClicked"]){
        NSLog(@"it's here");
        prefer.onlineORoffline = @"online";
    }else if([segue.identifier isEqualToString:@"offlineFriendClicked"]){
        prefer.onlineORoffline = @"offline";
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.tableView.rowHeight * 1.5;
}


-(void)cancelButtonPress:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section == 0)
    {
        return @"Available Friends";
    }
    else if(section == 1)
    {
        return @"Unavailable Friends";
    }
    else
    {
        return @"Title2";
    }
}
-(void)stopRKLoading
{
    self.tabBarController.tabBar.userInteractionEnabled = YES;
    [self.view setUserInteractionEnabled:YES];
    [loadingAnimation hideHUDForView:self.view animated:YES];
}

- (void) handleRefresh:(id)paramSender{
    /* Put a bit of delay between when the refresh control is released
     and when we actually do the refreshing to make the UI look a bit
     smoother than just doing the update without the animation */
    int64_t delayInSeconds = 1.0f;
    dispatch_time_t popTime =
    dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.refreshControl endRefreshing];
    });
    
}
- (IBAction)sortFriend:(id)sender {
    for (int m = 0; m < onlineFriendList.count; m++) {
        FriendList *myOnlineFriendListelement = [onlineFriendList objectAtIndex:m];
    for (int i = 0; i<onlineFriendList.count; i++) {
        FriendList *local = [onlineFriendList objectAtIndex:i];
        if (local.startTime.length > 8 && myOnlineFriendListelement.startTime.length > 8) {
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            [df setDateFormat:@"EEE,MM/dd hh:mm a"];
            for (int j = 0; j< onlineFriendList.count
                 ; j++) {
                NSDate *localDate = [[NSDate alloc]init];
                localDate = [df dateFromString:local.startTime];
                NSDate *newDate = [[NSDate alloc]init];
                newDate = [df dateFromString:myOnlineFriendListelement.startTime];
                if ([localDate compare:newDate] == NSOrderedDescending) {
                    [onlineFriendList insertObject:myOnlineFriendListelement atIndex:j];
                }
                break;
            }
            [onlineFriendList addObject:myOnlineFriendListelement];
            
        }else{
            [onlineFriendList insertObject:myOnlineFriendListelement atIndex:0];
        }
    }
    }
    [self.tableView reloadData];
}
@end
