//
//  SharedNotebook.h
//  Test1
//
//  Created by jenth on 12-8-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "EvernoteNoteStore.h"

@interface SharedNotebook : NSManagedObject

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSNumber * userId;
@property (nonatomic, retain) NSString * notebookGuid;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSNumber * notebookModifiable;
@property (nonatomic, retain) NSNumber * serviceCreated;
@property (nonatomic, retain) NSString * shareKey;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSNumber * requireLogin;

- (void)setShareNotebook:(EDAMSharedNotebook *)shareNotebook;
- (EDAMSharedNotebook *)getEDAMSharedNotebook;


@end
