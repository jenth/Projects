//
//  GroupModel.h
//  Test1
//
//  Created by jenth on 12-9-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GroupModel : NSObject
{
//    NSManagedObjectContext *context;
}

//@property (nonatomic, assign) NSManagedObjectContext *context;

+ (GroupModel *)getInstance;
- (void)addGroupWithName:(NSString *)name
                  target:(id)target action:(SEL)action;
- (void)addGroupUserList:(NSString *)gid userIds:(NSArray *)userIds 
                   nicks:(NSArray *)nicks emails:(NSArray *)emails
                  target:(id)target action:(SEL)action;
- (void)getGroupUser:(id)target action:(SEL)action;
- (void)deleteGroup:(NSString *)gid target:(id)target action:(SEL)action;
- (void)deleteGroupUser:(NSString *)gid userId:(NSString *)userId 
                 target:(id)target action:(SEL)action;

@end
