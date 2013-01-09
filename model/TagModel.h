//
//  NoteModel.h
//  Test1
//
//  Created by jenth on 12-5-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EvernoteNoteStore.h"

@interface TagModel : NSObject
{
//    NSArray *tagsList;
//    NSManagedObjectContext *context;
    
    BOOL tagEdit;
}

@property (nonatomic, assign) BOOL tagEdit;
//@property (nonatomic, assign) NSManagedObjectContext *context;

+ (TagModel *)getInstance;

// 同步Tag表
- (void)setTagsList:(NSArray *)tagsList 
       expungedTags:(NSArray *)expungedTags 
           isUpdate:(BOOL)isUpdate 
             linked:(BOOL)linked;

- (void)uploadTags:(NSArray *)clientTags;
- (void)createTag:(EDAMTag *)newTag;
- (NSArray *)getTagsByGuids:(NSArray *)guids;
- (NSArray *)getTagsList;

@end
