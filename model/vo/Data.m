//
//  Data.m
//  Test1
//
//  Created by jenth on 12-8-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "Data.h"


@implementation Data

@dynamic body;
@dynamic bodyHash;
@dynamic size;
@dynamic base64;

- (void)setData:(EDAMData *)data
{
    self.bodyHash = data.bodyHash;
    self.body = data.body;
    self.size = [NSNumber numberWithInt:data.size];
    self.base64 = nil;
}

- (EDAMData *)getEDAMData
{
    EDAMData *data = [[EDAMData alloc] init];
    data.body = self.body;
    data.bodyHash = self.bodyHash;
    data.size = [self.size intValue];
    
    return data;
}

@end
