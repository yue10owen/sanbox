//
//  simpleDBHelper.m
//  sandbox
//
//  Created by jake on 4/2/14.
//  Copyright (c) 2014 jake. All rights reserved.
//

#import "simpleDBHelper.h"
#import <AWSSimpleDB/AWSSimpleDB.h>
#import "AmazonClientManager.h"
@implementation simpleDBHelper
-(void) addAtrribute: (NSString*)doaminName item:(NSString*)itemName attribute:(NSString*)attributeName value:(NSString*)attributeValue{
    
    SimpleDBGetAttributesRequest* gar = [[SimpleDBGetAttributesRequest alloc] initWithDomainName:doaminName andItemName:itemName];
    SimpleDBGetAttributesResponse* response = [[AmazonClientManager sdb] getAttributes:gar];
    NSMutableArray *ListAttributes = [[NSMutableArray alloc] init];
    for (SimpleDBAttribute *attr in response.attributes ) {
        SimpleDBReplaceableAttribute *ListAttribute = [[SimpleDBReplaceableAttribute alloc] initWithName:attr.name andValue:attr.value andReplace:YES];
        [ListAttributes addObject:ListAttribute];
    }
    SimpleDBReplaceableAttribute *ListAttribute = [[SimpleDBReplaceableAttribute alloc] initWithName:attributeName andValue:attributeValue andReplace:YES];
    [ListAttributes addObject:ListAttribute];
    
    SimpleDBPutAttributesRequest *putAttributesRequest = [[SimpleDBPutAttributesRequest alloc] initWithDomainName:doaminName andItemName:itemName andAttributes:ListAttributes];
    AmazonSimpleDBClient *sdb = [AmazonClientManager sdb];
    [sdb putAttributes:putAttributesRequest];
    
}

-(void) updateAtrribute: (NSString*)doaminName item:(NSString*)itemName attribute:(NSString*)attributeName newValue:(NSString*)attributeValue{
    SimpleDBGetAttributesRequest* gar = [[SimpleDBGetAttributesRequest alloc] initWithDomainName:doaminName andItemName:itemName];
    SimpleDBGetAttributesResponse* response = [[AmazonClientManager sdb] getAttributes:gar];
    NSMutableArray *ListAttributes = [[NSMutableArray alloc] init];
    BOOL attributeExist = NO;
    for (SimpleDBAttribute *attr in response.attributes ) {
        SimpleDBReplaceableAttribute *ListAttribute;
        if ([attr.name isEqualToString:attributeName]) {
            attributeExist = YES;
            ListAttribute = [[SimpleDBReplaceableAttribute alloc] initWithName:attr.name andValue:attributeValue andReplace:YES];
        }else{
            ListAttribute = [[SimpleDBReplaceableAttribute alloc] initWithName:attr.name andValue:attr.value andReplace:YES];
        }
        [ListAttributes addObject:ListAttribute];
    }
    if (attributeExist) {
        SimpleDBPutAttributesRequest *putAttributesRequest = [[SimpleDBPutAttributesRequest alloc] initWithDomainName:doaminName andItemName:itemName andAttributes:ListAttributes];
        AmazonSimpleDBClient *sdb = [AmazonClientManager sdb];
        [sdb putAttributes:putAttributesRequest];
    }else{
        NSLog(@"The attribute does NOT exist");
    }
}


-(NSString*) getAtrributeValue: (NSString*)doaminName item:(NSString*)itemName attribute:(NSString*)attributeName{
    SimpleDBGetAttributesRequest* gar = [[SimpleDBGetAttributesRequest alloc] initWithDomainName:doaminName andItemName:itemName];
    SimpleDBGetAttributesResponse* response = [[AmazonClientManager sdb] getAttributes:gar];
    NSMutableArray *ListAttributes = [[NSMutableArray alloc] init];
    NSString* result = [[NSString alloc] init];
    BOOL attributeExist = NO;
    for (SimpleDBAttribute *attr in response.attributes ) {
        SimpleDBReplaceableAttribute *ListAttribute;
        if ([attr.name isEqualToString:attributeName]) {
            attributeExist = YES;
            result = attr.value;
        }else{
            ListAttribute = [[SimpleDBReplaceableAttribute alloc] initWithName:attr.name andValue:attr.value andReplace:YES];
            [ListAttributes addObject:ListAttribute];
        }
    }
    if (attributeExist) {
    }else{
        NSLog(@"The attribute does NOT exist");
    }
    return result;
}

@end
