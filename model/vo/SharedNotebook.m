//
//  SharedNotebook.m
//  Test1
//
//  Created by jenth on 12-8-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SharedNotebook.h"


@implementation SharedNotebook

@dynamic id;
@dynamic userId;
@dynamic notebookGuid;
@dynamic email;
@dynamic notebookModifiable;
@dynamic serviceCreated;
@dynamic shareKey;
@dynamic username;
@dynamic requireLogin;

- (void)setShareNotebook:(EDAMSharedNotebook *)shareNotebook
{
    self.id = [NSNumber numberWithInt:shareNotebook.id];
    self.userId = [NSNumber numberWithInt:shareNotebook.userId];
    self.notebookGuid = shareNotebook.notebookGuid;
    self.email = shareNotebook.email;
    self.notebookModifiable = [NSNumber numberWithBool:shareNotebook.notebookModifiable];
    self.serviceCreated = [NSNumber numberWithFloat:shareNotebook.serviceCreated];
    self.shareKey = shareNotebook.shareKey;
    self.username = shareNotebook.username;
    self.requireLogin = [NSNumber numberWithBool:shareNotebook.requireLogin];
}

- (EDAMSharedNotebook *)getEDAMSharedNotebook
{
    EDAMSharedNotebook *sharedNotebook = [[[EDAMSharedNotebook alloc] init] autorelease];
    sharedNotebook.id = [self.id intValue];
    sharedNotebook.userId = [self.userId intValue];
    sharedNotebook.notebookGuid = self.notebookGuid;
    sharedNotebook.email = self.email;
    sharedNotebook.notebookModifiable = [self.notebookModifiable boolValue];
    sharedNotebook.serviceCreated = [self.serviceCreated floatValue];
    sharedNotebook.shareKey = self.shareKey;
    sharedNotebook.username = self.username;
    sharedNotebook.requireLogin = [self.requireLogin intValue];
    return sharedNotebook;
}

@end
