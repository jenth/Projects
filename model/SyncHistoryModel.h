//
//  SyncHistoryModel.h
//  Test1
//
//  Created by jenth on 12-9-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SyncHistory.h"

@interface SyncHistoryModel : NSObject
{
//    NSManagedObjectContext *context;
}

//@property (readonly, strong, nonatomic) NSManagedObjectContext *context;

+ (SyncHistoryModel *)getInstance;
- (SyncHistory *)getSyncHistory;
- (void)updateSycHistory:(int)lastUpdateCount chunkHighUSN:(int)chunkHighUSN lastSyncTime:(int64_t)lastSyncTime;


@end
