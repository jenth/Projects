//
//  SyncHistory.h
//  Test1
//
//  Created by jenth on 12-9-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface SyncHistory : NSManagedObject

@property (nonatomic, retain) NSNumber * lastUpdateCount;
@property (nonatomic, retain) NSNumber * lastSyncTime;
@property (nonatomic, retain) NSNumber * chunkHighUSN;

@end
