//
//  NoteBookModel.h
//  Test1
//
//  Created by jenth on 12-5-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "EvernoteNoteStore.h"
#import "LinkedNotebook.h"
#import "Notebook.h"

@interface NotebookModel : NSObject
{
//    NSManagedObjectContext *context;
    NSOperationQueue *queue;
}

//@property (nonatomic, assign) NSManagedObjectContext *context;
@property (nonatomic, retain) NSOperationQueue *queue;

+ (NotebookModel *)getInstance;
// 同步Notebook表
- (void)setNotebooksList:(NSArray *)NotebooksList 
       expungedNotebooks:(NSArray *)expungedNotebooks 
                isUpdate:(BOOL)isUpdate linked:(int)linked;

/*******************************
 *
 * 笔记本处理
 *
 ********************************/

- (NSArray *) getNotebookList;
// 获取我共享的笔记本列表
- (NSArray *) getMySharedNotebookList;
// 默认笔记本
- (Notebook *) getDefaultNotebook;
// 创建笔记文件夹
- (void)createNotebook:(EDAMNotebook *)notebook;
- (void)setDefaultNotebook:(NSString *)guid;
- (Notebook *)getNotebookByGuid:(NSString *)guid;
- (void)setLinkedNoteboook:(NSArray *)linkedNotebooks;

@end
