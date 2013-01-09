//
//  Note.h
//  Test1
//
//  Created by jenth on 12-8-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "EvernoteNoteStore.h"
//#import "Evernote.h"

@interface Note : NSManagedObject

@property (nonatomic, retain) NSNumber * active;
@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSNumber * created;
@property (nonatomic, retain) NSNumber * deleted;
@property (nonatomic, retain) NSNumber * dirty;
@property (nonatomic, retain) NSString * guid;
@property (nonatomic, retain) NSString * notebookGuid;
@property (nonatomic, retain) NSString * tagGuids;
@property (nonatomic, retain) NSString * tagNames;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * updated;
@property (nonatomic, retain) NSNumber * updateSequenceNum;
@property (nonatomic, retain) NSNumber * linked;
@property (nonatomic, retain) NSNumber * cmtSequence;
@property (nonatomic, retain) NSData *thumbnails;
@property (nonatomic, retain) NSSet *resource;
@end

@interface Note (CoreDataGeneratedAccessors)

- (void)addResourceObject:(NSManagedObject *)value;
- (void)removeResourceObject:(NSManagedObject *)value;
- (void)addResource:(NSSet *)values;
- (void)removeResource:(NSSet *)values;

- (void)setNote:(EDAMNote *)edamNote;
- (EDAMNote *)getEDAMNote;

@end
