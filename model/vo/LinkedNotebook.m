//
//  LinkedNotebook.m
//  Test1
//
//  Created by jenth on 12-8-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "LinkedNotebook.h"


@implementation LinkedNotebook

@dynamic guid;
@dynamic noteStoreUrl;
@dynamic shardId;
@dynamic shareKey;
@dynamic shareName;
@dynamic updateSequenceNum;
@dynamic uri;
@dynamic username;
@dynamic sharedNotebook;


- (void)setLinkedNotebook:(EDAMLinkedNotebook *)linkedNotebook
{
    self.guid = linkedNotebook.guid;
    self.noteStoreUrl = linkedNotebook.noteStoreUrl;
    self.shardId = linkedNotebook.shardId;
    self.shareKey = linkedNotebook.shareKey;
    self.shareName = linkedNotebook.shareName;
    self.updateSequenceNum = [NSNumber numberWithInt:linkedNotebook.updateSequenceNum];
    self.uri = linkedNotebook.uri;
    self.username = linkedNotebook.username;
}


- (EDAMLinkedNotebook *)getEDAMLinkedNotebook
{
    EDAMLinkedNotebook *linkedNotebook = [[[EDAMLinkedNotebook alloc] init] autorelease];
    linkedNotebook.guid = self.guid;
    linkedNotebook.noteStoreUrl = self.noteStoreUrl;
    linkedNotebook.shardId = self.shardId;
    linkedNotebook.shareKey = self.shareKey;
    linkedNotebook.shareName = self.shareName;
    linkedNotebook.updateSequenceNum = [self.updateSequenceNum intValue];
    linkedNotebook.uri = self.uri;
    linkedNotebook.username = self.username;
    
    return linkedNotebook;
}

@end
