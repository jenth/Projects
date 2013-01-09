//
//  Resource.m
//  Test1
//
//  Created by jenth on 12-8-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "Resource.h"


@implementation Resource

@dynamic active;
@dynamic dirty;
@dynamic duration;
@dynamic guid;
@dynamic height;
@dynamic linked;
@dynamic mime;
@dynamic noteGuid;
@dynamic updateSequenceNum;
@dynamic width;
@dynamic attribute;
@dynamic data;


- (void)setResource:(EDAMResource *)resource
{
    self.active = [NSNumber numberWithBool:resource.active];
    self.guid = resource.guid;
    self.height = [NSNumber numberWithInt:resource.height];
    self.mime = resource.mime;
    self.noteGuid = resource.noteGuid;
    self.updateSequenceNum = [NSNumber numberWithInt:resource.updateSequenceNum];
    self.width = [NSNumber numberWithInt:resource.width];
}

- (EDAMResource *)getEDAMResource
{
    EDAMResource *resource = [[[EDAMResource alloc] init] autorelease];
    resource.active = [self.active boolValue];
    resource.guid = self.guid;
    resource.height = [self.height intValue];
    resource.mime = self.mime;
    resource.noteGuid = self.noteGuid;
    resource.width = [self.width intValue];
    
    return resource;
}

- (BOOL)isPic
{
    if([self.mime isEqualToString:MEDIA_JPEG]||
       [self.mime isEqualToString:MEDIA_GIF]||
       [self.mime isEqualToString:MEDIA_PNG])
    {
        return YES;
    }
    return NO;
}

@end
