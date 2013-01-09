//
//  Tag.h
//  Test1
//
//  Created by jenth on 12-8-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Tag : NSManagedObject

@property (nonatomic, retain) NSNumber * dirty;
@property (nonatomic, retain) NSString * guid;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * parentGuid;
@property (nonatomic, retain) NSNumber * updateSequenceNum;
@property (nonatomic, retain) NSNumber * linked;

@end
