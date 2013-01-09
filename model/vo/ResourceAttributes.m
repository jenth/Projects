//
//  ResourceAttributes.m
//  Test1
//
//  Created by jenth on 12-8-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ResourceAttributes.h"


@implementation ResourceAttributes

@dynamic sourceURL;
@dynamic timestamp;
@dynamic fileName;
@dynamic attachment;


- (void)setResourceAttributes:(EDAMResourceAttributes *)attributes
{
    self.sourceURL = attributes.sourceURL;
    self.timestamp = [NSNumber numberWithInt:attributes.timestamp];
    self.fileName = attributes.fileName;
    self.attachment = [NSNumber numberWithBool:attributes.attachment];
}


- (EDAMResourceAttributes *)gettResourceAttributes
{
    EDAMResourceAttributes *attributes = [[EDAMResourceAttributes alloc] init];
    attributes.sourceURL = self.sourceURL;
    attributes.timestamp = [self.timestamp intValue];
    attributes.fileName = self.fileName;
    attributes.attachment = [self.attachment boolValue];
    return attributes;
}

@end
