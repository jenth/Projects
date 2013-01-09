//
//  Note.m
//  Test1
//
//  Created by jenth on 12-8-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "Note.h"
#import <objc/runtime.h>

@implementation Note

@dynamic active;
@dynamic content;
@dynamic created;
@dynamic deleted;
@dynamic dirty;
@dynamic guid;
@dynamic notebookGuid;
@dynamic tagGuids;
@dynamic tagNames;
@dynamic title;
@dynamic updated;
@dynamic updateSequenceNum;
@dynamic linked;
@dynamic thumbnails;
@dynamic resource;
@dynamic cmtSequence;

- (void)setNote:(EDAMNote *)edamNote
{
    self.active = [NSNumber numberWithBool:edamNote.active];
    self.content = edamNote.content;
    self.created = [NSNumber numberWithFloat:edamNote.created];
    self.deleted = [NSNumber numberWithFloat:edamNote.created];
    self.guid = edamNote.guid;
    self.notebookGuid = edamNote.notebookGuid;
    if([edamNote.tagGuids count]>0) {
        self.tagGuids =[edamNote.tagGuids componentsJoinedByString:@","];
    }
    if([edamNote.tagNames count]>0) {
        self.tagNames =[edamNote.tagNames componentsJoinedByString:@","];
    } 
    self.title = edamNote.title;
    self.updated = [NSNumber numberWithFloat:edamNote.updated];
    self.updateSequenceNum = [NSNumber numberWithInt:edamNote.updateSequenceNum];
}


- (EDAMNote *)getEDAMNote
{
    EDAMNote *note = [[EDAMNote alloc] init];
    note.active = [self.active boolValue];
    note.content= self.content;
    note.created= [self.created floatValue];
    note.guid = self.guid;
    note.notebookGuid = self.notebookGuid;
    if (self.tagGuids) {
        note.tagGuids = [self.tagGuids componentsSeparatedByString:@","];
    }
    if (self.tagNames) {
        note.tagNames = [self.tagNames componentsSeparatedByString:@","];
    }
    note.title = self.title;
    return note;
}


@end
