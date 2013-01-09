//
//  NoteModel.h
//  Test1
//
//  Created by jenth on 12-5-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EvernoteNoteStore.h"
#import "Note.h"
#import "Resource.h"
#import "Data.h"
#import "ResourceAttributes.h"


@interface NoteModel : NSThread
{
//    NSManagedObjectContext *context;
}

@property (nonatomic, retain) NSMutableArray *needSyncNoteGuids;
@property (nonatomic, retain) NSMutableArray *noteGuidsList;
@property (nonatomic, retain) NSMutableArray *needSyncResourceGuids;
//@property (nonatomic, assign) NSManagedObjectContext *context;

+ (NoteModel *)getInstance;
// 同步Note表
- (void)setNotesList:(NSArray *)notesList 
       expungedNotes:(NSArray *)expungedNotes 
            isUpdate:(BOOL)isUpdate 
              linked:(BOOL)linked  
       sharedAuthKey:(NSString *)sharedAuthKey
      linkedNotebook:(EDAMLinkedNotebook *)linkedNotebook;
// 通过记事本id获取，记事本内笔记
- (NSArray *)getNotesByNotebookId:(NSString *)guid;
- (Resource *)getResourceByGuid:(NSString *)guid;
// 删除笔记
- (void)deleteNote:(NSString *)guid;
// 获取日子留言评论
- (EDAMNoteList *)getNoteCommand:(NSString *)noteGuid;
// 设置笔记本
- (void)setTags:(NSString *)noteGuid tagGuids:(NSString *)tagGuids;
// 设置笔记本
- (void)setNotebook:(NSString *)noteGuid 
       notebookGuid:(NSString *)notebookGuid;
//- (void)syncNote:(NSDictionary *)data;
//- (void)saveResource:(NSDictionary *)data;
- (void)updateResourceData:(NSData *)data resGuid:(NSString *)resGuid;
- (NSArray *)getHomePhoto:(int)num;
- (Note *)getNoteByGuid:(NSString *)guid;
- (void)saveNoteContent:(NSString *)guid content:(NSString *)content;
- (void)saveResourceData:(NSString *)guid data:(NSData *)body;
- (NSArray *)getNoteByGuidList:(NSArray *)guids;
- (void)saveNoteThumbnail:(NSString *)guid thumbnailData:(NSData *)thumbnailData;
- (NSArray *)queryNotes:(NSPredicate *)pred;
- (void)setNoteCommentSeq:(NSString *)guid seq:(int)seq;
- (void)syncNotesList;
- (void)syncResourceList;
- (NSArray *)getResourceDataNullList;

@end
