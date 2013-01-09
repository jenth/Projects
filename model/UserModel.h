//
//  UserModel.h
//  Test1
//
//  Created by jenth on 12-9-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EvernoteUserStore.h"

@interface UserModel : NSObject
{
    EDAMUser *user;
}

@property (nonatomic, retain) EDAMUser *user;

+ (UserModel *)getInstance;
@end
