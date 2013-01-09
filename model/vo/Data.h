//
//  Data.h
//  Test1
//
//  Created by jenth on 12-8-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "EvernoteNoteStore.h"

@interface Data : NSManagedObject

@property (nonatomic, retain) NSData * body;
@property (nonatomic, retain) NSData * bodyHash;
@property (nonatomic, retain) NSNumber * size;
@property (nonatomic, retain) NSString * base64;


- (void)setData:(EDAMData *)data;
- (EDAMData *)getEDAMData;

@end
