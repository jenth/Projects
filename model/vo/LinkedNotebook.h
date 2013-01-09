//
//  LinkedNotebook.h
//  Test1
//
//  Created by jenth on 12-8-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "EvernoteNoteStore.h"
#import "SharedNotebook.h"

@interface LinkedNotebook : NSManagedObject

@property (nonatomic, retain) NSString * guid;
@property (nonatomic, retain) NSString * noteStoreUrl;
@property (nonatomic, retain) NSString * shardId;
@property (nonatomic, retain) NSString * shareKey;
@property (nonatomic, retain) NSString * shareName;
@property (nonatomic, retain) NSNumber * updateSequenceNum;
@property (nonatomic, retain) NSString * uri;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) SharedNotebook *sharedNotebook;

- (void)setLinkedNotebook:(EDAMLinkedNotebook *)linkedNotebook;
- (EDAMLinkedNotebook *)getEDAMLinkedNotebook;


@end
