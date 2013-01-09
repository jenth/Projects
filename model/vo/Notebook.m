//
//  Notebook.m
//  Test1
//
//  Created by jenth on 12-8-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "Notebook.h"


@implementation Notebook

@dynamic defaultNotebook;
@dynamic dirty;
@dynamic guid;
@dynamic name;
@dynamic published;
@dynamic publishing;
@dynamic serviceCreated;
@dynamic serviceUpdated;
@dynamic sharedNotebookIds;
@dynamic stack;
@dynamic updateSequenceNum;
@dynamic linked;

- (void)setNotebook:(EDAMNotebook *)notebook
{
    self.defaultNotebook = [NSNumber numberWithInt:notebook.defaultNotebook];
    self.guid = notebook.guid;
    self.name = notebook.name;
    self.published = [NSNumber numberWithBool:notebook.published];
    self.serviceCreated = [NSNumber numberWithFloat:notebook.serviceCreated];
    self.serviceUpdated = [NSNumber numberWithFloat:notebook.serviceUpdated];
    if ([notebook.sharedNotebookIds count]>0) {
        self.sharedNotebookIds = [notebook.sharedNotebookIds componentsJoinedByString:@","];
    }
    self.stack = notebook.stack;
    self.updateSequenceNum = [NSNumber numberWithInt:notebook.updateSequenceNum];
}

- (EDAMNotebook *)getEDAMNotebook
{
    EDAMNotebook *notebook = [[[EDAMNotebook alloc] init] autorelease];
    notebook.defaultNotebook = [self.defaultNotebook boolValue];
    notebook.guid = self.guid;
    notebook.name = self.name;
    if (notebook.sharedNotebookIds) {
        notebook.sharedNotebookIds = [self.sharedNotebookIds componentsSeparatedByString:@","];
    }
    notebook.stack = self.stack;
    notebook.updateSequenceNum = [self.updateSequenceNum intValue];
    
    return notebook;
}

@end
