//
//  ShareModel.h
//  Test1
//
//  Created by jenth on 12-8-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EvernoteNoteStore.h"
#import "LinkedNotebook.h"
#import "SharedNotebook.h"

@interface ShareModel : NSObject
{
//    NSManagedObjectContext *context;
}

//@property (nonatomic, assign) NSManagedObjectContext *context;

+ (ShareModel *)getInstance;
- (void)setLinkedNoteboook:(EDAMLinkedNotebook *)linkedNotebook 
            sharedNotebook:(EDAMSharedNotebook *)sharedNotebook;
- (NSArray *)getLinkedNotebook;
- (void)sendUserShareMessage:(NSString *)email noteName:(NSString *)noteName 
                    shareUrl:(NSString *)shareUrl
                      target:(id)target action:(SEL)action;
- (void)addSharebooks:(NSArray *)sharebooks;
- (void)addSharebook:(EDAMSharedNotebook *)edamSharedNotebook;
- (NSArray *)getSharedNotebooksWithNotebookGuid:(NSString *)guid;
- (LinkedNotebook *)getLinkedNotebookByShareKey:(NSString *)shareKey;
- (void)createShares:(NSArray *)emalsList notebookGuid:(NSString *)notebookGuid notebookName:(NSString *)notebookName;
- (void)syncShareNotebook;
- (void)addLinkedList:(NSArray *)list;

@end
