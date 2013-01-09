//
//  UserModel.m
//  Test1
//
//  Created by jenth on 12-9-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "UserModel.h"

@implementation UserModel

@synthesize user;

static UserModel *instance = nil;

+ (UserModel *)getInstance {
    
    if (instance == nil) {        
        instance = [[UserModel alloc] init];
        
    }
    
    return instance;
}

@end
