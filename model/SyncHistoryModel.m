//
//  SyncHistoryModel.m
//  Test1
//
//  Created by jenth on 12-9-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SyncHistoryModel.h"
#import "CoreDataManager.h"

@implementation SyncHistoryModel

//@synthesize context=_context;

static SyncHistoryModel *instance = nil;
+ (SyncHistoryModel *)getInstance {
    
    if (instance == nil) {        
        instance = [[SyncHistoryModel alloc] init];
    }
    return instance;
}

- (id)init
{
    self = [super init];
//    context = [[CoreDataManager sharedInstance] managedObjectContext];
    return  self;
}

- (NSManagedObjectContext *)context
{
    return [[CoreDataManager sharedInstance] managedObjectContext];
}

- (SyncHistory *)getSyncHistory
{
    NSError *error;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"SyncHistory"
                                                         inManagedObjectContext:[self context]];
    [request setEntity:entityDescription];
    
    NSArray *objects = [[self context] executeFetchRequest:request error:&error];
    
    if (objects == nil){
        NSLog(@"There was an error!");
    }

    if ([objects count]>0) {
        return [objects objectAtIndex:0];
    }
    return nil;
}

- (void)updateSycHistory:(int)lastUpdateCount chunkHighUSN:(int)chunkHighUSN lastSyncTime:(int64_t)lastSyncTime
{
//    NSError *error;
    SyncHistory *history = [self getSyncHistory];
    if (!history) {
        history = [NSEntityDescription insertNewObjectForEntityForName:@"SyncHistory" 
                                                inManagedObjectContext:[self context]];
    }
    history.lastSyncTime = [NSNumber numberWithFloat:lastSyncTime];
    history.lastUpdateCount = [NSNumber numberWithInt:lastUpdateCount];
    history.chunkHighUSN = [NSNumber numberWithInt:chunkHighUSN];
    
    //[[self context] save:&error];
}

@end
