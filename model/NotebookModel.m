//
//  NotebookModel.m
//  Test1
//
//  Created by jenth on 12-5-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NotebookModel.h"
#import "AppDelegate.h"
#import "CoreDataManager.h"
#import "ShareModel.h"

@implementation NotebookModel

static NotebookModel *instance = nil;

@synthesize  queue;

+ (NotebookModel *)getInstance 
{
    if (instance == nil) {        
        instance = [[NotebookModel alloc] init];
    }
    
    return instance;
}

- (id)init
{
    self = [super init];
    
//    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
//    self.context = [[CoreDataManager sharedInstance] managedObjectContext];
    
    queue = [[NSOperationQueue alloc] init];
    
    return self;
}


- (NSManagedObjectContext *)context
{
    return [[CoreDataManager sharedInstance] managedObjectContext];
}

// 同步Notebook表
- (void)setNotebooksList:(NSArray *)NotebooksList 
       expungedNotebooks:(NSArray *)expungedNotebooks 
                isUpdate:(BOOL)isUpdate linked:(int)linked
{

    NSError *error;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Notebook"
                                                         inManagedObjectContext:[self context]];
    [request setEntity:entityDescription];
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(linked = %i)", linked];
    [request setPredicate:pred];
    
    NSArray *objects = [[self context] executeFetchRequest:request error:&error];
    
    if (objects == nil){
        NSLog(@"There was an error!");
    }
    
    [self addAndEditNotebooks:NotebooksList 
                 oldNotebooks:objects 
                       linked:linked];
    
    // 删除服务器同步下，删除的数据
    if (isUpdate) // 中间更新数据，服务器有返回已经删除的数据
    { 
        [self deleteExpungedNotebooks:expungedNotebooks 
                         oldNotebooks:objects];
    }
    /*** 本地不编辑笔记，不需要比对本地的数据
     暂时屏蔽
    else // 初始更新，比对服务器返回的数据和客服端的比对
    { 
        [self deleteTrunkNotebooks:NotebooksList 
                      oldNotebooks:objects]; 
    }
     ********/
    
    [request release];
    //[[self context] save:&error];
    
}


// 添加编辑标签
- (void)addAndEditNotebooks:(NSArray *)newNotebooks 
               oldNotebooks:(NSArray *)oldNotebooks 
                     linked:(BOOL)linked
{
    Notebook *theNotebook = nil;
    EDAMNotebook *notebook = nil;
    
    for (notebook in newNotebooks) 
    {
        BOOL isNew = YES;
        
        for (theNotebook in oldNotebooks) 
        {
            // 标签name相同且guide不同
            if ([notebook.name isEqualToString:theNotebook.name] &&
                ![notebook.guid isEqualToString:theNotebook.guid]) {
                
                // 本地做了修改，则合并处理或解决冲突
                if ([theNotebook.dirty boolValue]) 
                {
                    NSString *newName = [NSString stringWithFormat:@"%@(2)",theNotebook.name];
                    [theNotebook setValue:newName forKey:@"name"];
                }
                else // 
                {
                    
                    NSString *newName = [NSString stringWithFormat:@"%@(2)",theNotebook.name];
                    [theNotebook setValue:newName forKey:@"name"];
                }
            }
            // 同一个标签
            else if ([notebook.guid isEqualToString:[theNotebook valueForKey:@"guid"]]) 
            {
                // 更新时间相同
                if (notebook.updateSequenceNum==[theNotebook.updateSequenceNum intValue]) 
                {
                    // 本地做了修改, 则提交最新修改到服务器
                    if ([theNotebook.dirty boolValue]) {
                        
                    }
                    
                }
                // 服务器做了最新修改
                else if (notebook.updateSequenceNum >[theNotebook.updateSequenceNum intValue]) 
                {
                    // 本地也做了修改， 则合并处理或解决冲突
                    if ([theNotebook.dirty boolValue]) 
                    {
                        [theNotebook setValue:[NSNumber numberWithBool:NO] forKey:@"dirty"];
                    }
                    else // 本地没做修改，则更新服务数据到客户端
                    {
                        
                    }
                    [theNotebook setNotebook:notebook];
                }
                
                isNew = NO;
                // 标签已经存在继续执行
                break;
            }
        }
        
        // If a Notebook exists in the server’s list, but not in the client, add to the client DB
        if (isNew) {
            theNotebook = [NSEntityDescription insertNewObjectForEntityForName:@"Notebook" 
                                                    inManagedObjectContext:[self context]];
            [theNotebook setNotebook:notebook];
            theNotebook.dirty = [NSNumber numberWithBool:NO];
            theNotebook.linked = [NSNumber numberWithBool:linked];
        }
        
        [[ShareModel getInstance] addSharebooks:notebook.sharedNotebooks];
        
    }    
}


// 初始更新时，删除在服务端已经删除的数据
- (void)deleteTrunkNotebooks:(NSArray *)newNotebooks 
                oldNotebooks:(NSArray *)oldNotebooks
{
    NSManagedObject *theNotebook = nil;
    EDAMNotebook *notebook = nil;
    // 查找服务器上不存在，而本地存在的数据，则删除本地的数据
    for (theNotebook in oldNotebooks) {
        
        BOOL isDelete = YES;
        for (notebook in newNotebooks) 
        {
            if ([[theNotebook valueForKey:@"guid"] isEqualToString:notebook.guid] ||
                [[theNotebook valueForKey:@"dirty"] boolValue]) 
            {
                isDelete = NO;
                // 标签已经存在继续执行
                break;
            }
        }
        
        // 只存在在客户端，服务端不存在，则删除客户端数据
        if (isDelete) {
            [[self context] deleteObject:theNotebook];
        }
    }
}


// 删除中间更新时，服务器删除的数据
- (void)deleteExpungedNotebooks:(NSArray *)expungedNotebooks 
                   oldNotebooks:(NSArray *)oldNotebooks
{
    NSManagedObject *theNotebook = nil;
    NSString   *expungedNotebook = nil;
    // 查找服务器上不存在，而本地存在的数据，则删除本地的数据
    for (expungedNotebook in expungedNotebooks) {
        for (theNotebook in oldNotebooks) 
        {
            if ([[theNotebook valueForKey:@"guid"] isEqualToString:expungedNotebook]) 
            {
                [[self context] deleteObject:theNotebook];
            }
        }
    }
}


/*******************************
 *
 * 笔记本处理
 *
********************************/

// 获取我的笔记本列表
- (NSArray *) getNotebookList
{
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(sharedNotebookIds = null)"];
    return [self searchNotebookList:pred];
}

// 获取我共享的笔记本列表
- (NSArray *) getMySharedNotebookList
{
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(sharedNotebookIds <> null AND linked=0)"];
    return [self searchNotebookList:pred];
}

// 默认笔记本
- (EDAMNotebook *) getDefaultNotebook
{
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(defaultNotebook = %i)", 1];
    NSArray *notebooks = [self searchNotebookList:pred];
    if ([notebooks count]>0) {
        return [notebooks objectAtIndex:0];
    }else {
        return nil;
    }
}


// 通过笔记本id获取
- (Notebook *)getNotebookByGuid:(NSString *)guid;
{
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(guid = %@)", guid];
    NSArray *notebooks = [self searchNotebookList:pred];
    if ([notebooks count]>0) {
        return [notebooks objectAtIndex:0];
    }else {
        return nil;
    }
}

- (NSArray *) searchNotebookList:(NSPredicate *)pred
{

    NSError *error;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Notebook"
                                                         inManagedObjectContext:[self context]];
    [request setEntity:entityDescription];
    
    if (pred) {
        [request setPredicate:pred];
    }
    
    NSArray *objects = [[[self context] executeFetchRequest:request error:&error] retain];
    
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"serviceUpdated" 
                                                                 ascending:NO];
    objects = [objects sortedArrayUsingDescriptors:[NSArray arrayWithObject:descriptor]];
    
    if (objects == nil){
        NSLog(@"There was an error!");
    }
    [request release];
    
    return [objects autorelease];
}

// 设置默认
- (void)setDefaultNotebook:(NSString *)guid
{
    NSError *error;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Notebook"
                                                         inManagedObjectContext:[self context]];
    [request setEntity:entityDescription];
    
     NSPredicate *pred = [NSPredicate predicateWithFormat:@"(defaultNotebook = %i)", 1];
    [request setPredicate:pred];
    
    NSArray *objects = [[self context] executeFetchRequest:request error:&error];
    
    
    if (objects == nil){
        NSLog(@"There was an error!");
    }
    
    NSManagedObject *theNotebook = [objects objectAtIndex:0];
    [theNotebook setValue:[NSNumber numberWithInt:0] forKey:@"defaultNotebook"];
    [theNotebook setValue:[NSNumber numberWithBool:YES] forKey:@"dirty"];
    //[[self context] save:&error];

    
    pred = [NSPredicate predicateWithFormat:@"(guid = %@)", guid];
    [request setPredicate:pred];
    objects = [[self context] executeFetchRequest:request error:&error];
    if (objects == nil){
        NSLog(@"There was an error!");
    }
    
    theNotebook = [objects objectAtIndex:0];
    [theNotebook setValue:[NSNumber numberWithInt:1] forKey:@"defaultNotebook"];
    [theNotebook setValue:[NSNumber numberWithBool:YES] forKey:@"dirty"];
    //[[self context] save:&error];
}

// 创建笔记文件夹
- (void)createNotebook:(EDAMNotebook *)notebook
{
    NSError *error;
    
    Notebook  *theNotebook = [NSEntityDescription insertNewObjectForEntityForName:@"Notebook" 
                                                              inManagedObjectContext:[self context]];
    
    [theNotebook setNotebook:notebook];
    [theNotebook setValue:[NSNumber numberWithBool:YES] forKey:@"dirty"];
    //[[self context] save:&error];
}


- (void)deleteNotebook:(NSString *)notebookGuid
{
    
}




@end
