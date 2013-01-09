//
//  ResourceAttributes.h
//  Test1
//
//  Created by jenth on 12-8-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "EvernoteNoteStore.h"

@interface ResourceAttributes : NSManagedObject

@property (nonatomic, retain) NSString * sourceURL;
@property (nonatomic, retain) NSNumber * timestamp;
@property (nonatomic, retain) NSString * fileName;
@property (nonatomic, retain) NSNumber * attachment;

- (void)setResourceAttributes:(EDAMResourceAttributes *)attributes;
- (EDAMResourceAttributes *)gettResourceAttributes;

@end
