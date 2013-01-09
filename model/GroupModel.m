//
//  GroupModel.m
//  Test1
//
//  Created by jenth on 12-9-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "GroupModel.h"
#import "CoreDataManager.h"
#import "WebServiceUrl.h"
#import "UserModel.h"
#import "WebService.h"

@implementation GroupModel

//@synthesize context;

static GroupModel *instance = nil;

+ (GroupModel *)getInstance {
    
    if (instance == nil) {        
        instance = [[GroupModel alloc] init];
    }
    return instance;
}

- (id)init
{
    self = [super init];
    
//    self.context = [[CoreDataManager sharedInstance] managedObjectContext];
    
    return self;
}

- (NSManagedObjectContext *)context
{
    return [[CoreDataManager sharedInstance] managedObjectContext];
}

#pragma mark ------请求后台API-------------- 

/******
 POST参数：uid 创建工作组的的用户EVERNOTE_ID
        name 工作组的名称
 *******/
- (void)addGroupWithName:(NSString *)name
                  target:(id)target action:(SEL)action
{
    NSString *url = [WebServiceUrl getUrl:@"GroupAdd"];
    
    EDAMUser *user = [UserModel getInstance].user;
    NSMutableDictionary *data = [NSMutableDictionary dictionaryWithCapacity:3];
    [data setValue:[NSNumber numberWithInt:user.id] forKey:@"uid"];
    [data setValue:name forKey:@"name"];
    
    [WebService requestWithUrl:url
                      postData:data
                        target:target action:action];
}


/******
 POST参数：gid  工作组ID；
         uid 创建此工作的的用户EVERNOTE_ID；
         guid[]   注意有“[]”号，工作组成员的EVERNOTE_ID
         nick[]	   工作组成员的备注（昵称）
         email[]  工作组成员的EMAIL
         以上3个参数需一一对应；

 *******/

- (void)addGroupUserList:(NSString *)gid userIds:(NSArray *)userIds 
                  nicks:(NSArray *)nicks emails:(NSArray *)emails
                  target:(id)target action:(SEL)action
{
    NSString *url = [WebServiceUrl getUrl:@"GroupAddUser"];
    
    EDAMUser *user = [UserModel getInstance].user;
    NSMutableDictionary *data = [NSMutableDictionary dictionaryWithCapacity:3];
    [data setValue:[NSNumber numberWithInt:user.id] forKey:@"uid"];
    [data setValue:gid forKey:@"gid"];
    for (int i=0; i<[userIds count]; i++) 
    {
        [data setValue:[userIds objectAtIndex:i] 
                forKey:[NSString stringWithFormat:@"guid[%i]", i]];
        [data setValue:[nicks objectAtIndex:i] 
                forKey:[NSString stringWithFormat:@"nick[%i]", i]];
        [data setValue:[emails objectAtIndex:i] 
                forKey:[NSString stringWithFormat:@"email[%i]", i]];
    }
    
    [WebService requestWithUrl:url
                      postData:data
                        target:target action:action];
}

/******
 POST参数：uid  使用者的用户EVERNOTE_ID
 
 *******/

- (void)getGroupUser:(id)target action:(SEL)action
{
    NSString *url = [WebServiceUrl getUrl:@"GroupUser"];
    
    EDAMUser *user = [UserModel getInstance].user;
    NSMutableDictionary *data = [NSMutableDictionary dictionaryWithCapacity:1];
    [data setValue:[NSNumber numberWithInt:user.id] forKey:@"uid"];
    
    [WebService requestWithUrl:url
                      postData:data
                        target:target action:action];
}

/******
 POST参数：uid  工作组创建者的用户EVERNOTE_ID
 gid  工作组ID
 type 值有：group  当前操作表示删除工作组；
          guser   当前操作表示删除工作组的成员；
 
 guid  需删除的工作组的成员的EVERNOTE_ID。此参数在type=guser时带上
 *******/
- (void)deleteGroup:(NSString *)gid target:(id)target action:(SEL)action
{
    NSString *url = [WebServiceUrl getUrl:@"GroupDel"];
    
    EDAMUser *user = [UserModel getInstance].user;
    NSMutableDictionary *data = [NSMutableDictionary dictionaryWithCapacity:1];
    [data setValue:[NSNumber numberWithInt:user.id] forKey:@"uid"];
    [data setValue:gid forKey:@"gid"];
    [data setValue:@"group" forKey:@"type"];
    
    [WebService requestWithUrl:url
                      postData:data
                        target:target action:action];
}

- (void)deleteGroupUser:(NSString *)gid userId:(NSString *)userId 
                 target:(id)target action:(SEL)action
{
    NSString *url = [WebServiceUrl getUrl:@"GroupDel"];
    
    EDAMUser *user = [UserModel getInstance].user;
    NSMutableDictionary *data = [NSMutableDictionary dictionaryWithCapacity:1];
    [data setValue:[NSNumber numberWithInt:user.id] forKey:@"uid"];
    [data setValue:gid forKey:@"gid"];
    [data setValue:@"guser" forKey:@"type"];
    [data setValue:userId forKey:@"guid"];
    
    [WebService requestWithUrl:url
                      postData:data
                        target:target action:action];
}

@end
