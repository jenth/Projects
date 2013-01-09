//
//  Notebook.h
//  Test1
//
//  Created by jenth on 12-8-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "EvernoteNoteStore.h"

@interface Notebook : NSManagedObject

@property (nonatomic, retain) NSNumber * defaultNotebook;
@property (nonatomic, retain) NSNumber * dirty;
@property (nonatomic, retain) NSString * guid;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * published;
@property (nonatomic, retain) NSString * publishing;
@property (nonatomic, retain) NSNumber * serviceCreated;
@property (nonatomic, retain) NSNumber * serviceUpdated;
@property (nonatomic, retain) NSString * sharedNotebookIds;
@property (nonatomic, retain) NSString * stack;
@property (nonatomic, retain) NSNumber * updateSequenceNum;
@property (nonatomic, retain) NSNumber * linked;

- (void)setNotebook:(EDAMNotebook *)notebook;
- (EDAMNotebook *)getEDAMNotebook;

@end
