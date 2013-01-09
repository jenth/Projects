//
//  NoteModel.m
//  Test1
//
//  Created by jenth on 12-5-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NoteModel.h"
#import "AppDelegate.h"
#import "AppGlobal.h"
#import "CoreDataManager.h"
#import "NoteService.h"
#import "ShareModel.h"
#import "EvernoteShareNoteStore.h"
#import "QueueLoader.h"
#import "NSData+Util.h"

@implementation NoteModel

@synthesize noteGuidsList=_noteGuidsList, needSyncNoteGuids=_needSyncNoteGuids;
@synthesize needSyncResourceGuids=_needSyncResourceGuids;

static NoteModel *instance = nil;

+ (NoteModel *)getInstance {
    
    if (instance == nil) {        
        instance = [[NoteModel alloc] init];
    }
    
    return instance;
}

- (id)init
{
    self = [super init];
    _needSyncNoteGuids = [[NSMutableArray alloc] initWithCapacity:1];
    _needSyncResourceGuids = [[NSMutableArray alloc] initWithCapacity:1];
//    self.context = [[CoreDataManager sharedInstance] managedObjectContext];
    
    return self;
}

- (NSManagedObjectContext *)context
{
    return [[CoreDataManager sharedInstance] managedObjectContext];
}

// 同步Note表
- (void)setNotesList:(NSArray *)notesList 
       expungedNotes:(NSArray *)expungedNotes 
            isUpdate:(BOOL)isUpdate 
              linked:(BOOL)linked  
       sharedAuthKey:(NSString *)sharedAuthKey
      linkedNotebook:(EDAMLinkedNotebook *)linkedNotebook
{
    NSError *error;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Note"
                                                         inManagedObjectContext:[self context]];   
    [request setEntity:entityDescription];
    
    NSPredicate *pred;
    if (linked) {
        if ( [notesList count]>0) {
            EDAMNote *note = [notesList objectAtIndex:0];
            pred = [NSPredicate predicateWithFormat:@"(linked = %i and notebookGuid=%@)", linked, note.notebookGuid];
            [request setPredicate:pred];
        }
    }else {
        pred = [NSPredicate predicateWithFormat:@"(linked = %i)", linked];
        [request setPredicate:pred];
    }
    
    
    NSArray *objects = [[self context] executeFetchRequest:request error:&error];
    
    if (objects == nil){
        NSLog(@"There was an error!");
    }
    
    [self addAndEditNotes:notesList 
                 oldNotes:objects 
                   linked:linked 
            sharedAuthKey:sharedAuthKey
           linkedNotebook:linkedNotebook];
    
    // 删除服务器同步下，删除的数据
    if (isUpdate) // 中间更新数据，服务器有返回已经删除的数据
    { 
        [self deleteExpungedNotes:expungedNotes 
                         oldNotes:objects];
    }
    /*** 本地不编辑笔记，不需要比对本地的数据
         暂时屏蔽
    else // 初始更新，比对服务器返回的数据和客服端的比对
    { 
        [self deleteTrunkNotes:notesList
                      oldNotes:objects]; 
    }
    ****/
    [request release];
    //[[self context] save:&error];

}


// 添加编辑标签
- (void)addAndEditNotes:(NSArray *)newNotes 
               oldNotes:(NSArray *)oldNotes 
                 linked:(BOOL)linked 
          sharedAuthKey:(NSString *)sharedAuthKey
         linkedNotebook:(EDAMLinkedNotebook *)linkedNotebook
{
    Note *theNote = nil;
    EDAMNote *note = nil;
    
    for (note in newNotes) 
    {
        BOOL isNew = YES;
        
        for (theNote in oldNotes) 
        {            
            if ([note.guid isEqualToString:theNote.guid]) 
            {
                // 更新时间相同
                if (note.updateSequenceNum==[theNote.updateSequenceNum intValue]) 
                {
                    // 本地做了修改, 则提交最新修改到服务器
                    if ([theNote.dirty boolValue]) {
                        
                    }
                    
                }
                // 服务器做了最新修改
                else if (note.updateSequenceNum >[theNote.updateSequenceNum intValue]) 
                {
                    // 需同步笔记详情
                    [theNote setNote:note];
                    theNote.linked = [NSNumber numberWithBool:NO];
                    theNote.dirty = [NSNumber numberWithBool:NO];
                    
                    NSArray *resList = note.resources;
                    for (int i=0; i<[resList count]; i++) {
                        EDAMResource *edamResource = [resList objectAtIndex:i];
                        
                        Resource *resource = nil;
                        for (Resource *theResource in [theNote.resource allObjects]) {
                            if ([theResource.guid isEqualToString:edamResource.guid]) {
                                resource = theResource;
                            }
                        }
                        if (resource==nil) {
                            resource = [NSEntityDescription insertNewObjectForEntityForName:@"Resource" 
                                                                     inManagedObjectContext:[self context]];
                            Data *data = [NSEntityDescription insertNewObjectForEntityForName:@"Data" 
                                                                       inManagedObjectContext:[self context]];
                            [data setData:edamResource.data];
                            
                            ResourceAttributes *attributes = [NSEntityDescription insertNewObjectForEntityForName:@"ResourceAttributes" 
                                                                                           inManagedObjectContext:[self context]];
                            [attributes setResourceAttributes:edamResource.attributes];
                            
                            resource.data = data;
                            resource.attribute = attributes;
                            [theNote addResourceObject:resource];
                        }
             
                        [resource setResource:edamResource];
                        resource.linked = [NSNumber numberWithBool:linked];
                        
                        if([resource isPic])
                        {
                            NSDictionary *data;
                            if (sharedAuthKey) {
                                data = [NSDictionary dictionaryWithObjectsAndKeys:resource.guid, @"guid",
                                        sharedAuthKey,@"sharedAuthKey", nil];
                            }else{
                                data = [NSDictionary dictionaryWithObjectsAndKeys:resource.guid, @"guid", nil];
                            }
                            [_needSyncResourceGuids addObject:data];
                        }
                    }
                    
                    NSDictionary *data;
                    if (sharedAuthKey) {
                        data = [NSDictionary dictionaryWithObjectsAndKeys:note.guid, @"guid",
                                                            sharedAuthKey,@"sharedAuthKey", nil];
                        
                        NSString *url = [AppGlobal getNoteThumbnailWithShareId:linkedNotebook.shardId
                                                                      noteGuid:note.guid size:160];
                        
                        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:sharedAuthKey, @"auth", nil];
                        
                        [QueueLoader addRequest:url param:dic userInfo:data
                                    reponseType:QueueBinary
                                       sendType:@"post"
                                         taregt:self selector:@selector(requestFinished:userInfo:)];
                        
                    }else{
                        data = [NSDictionary dictionaryWithObjectsAndKeys:note.guid, @"guid", nil];
                    }
                    [_needSyncNoteGuids addObject:data];
                }
                
                isNew = NO;
                // 标签已经存在继续执行
                break;
            }
        }
        
        // If a Note exists in the server’s list, but not in the client, add to the client DB
        if (isNew) {
            theNote = [NSEntityDescription insertNewObjectForEntityForName:@"Note" 
                                                   inManagedObjectContext:[self context]];
            [theNote setNote:note];
            theNote.dirty = [NSNumber numberWithBool:NO];
            theNote.linked = [NSNumber numberWithBool:linked];
            
            NSArray *resList = note.resources;
            for (int i=0; i<[resList count]; i++) {
                EDAMResource *edamResource = [resList objectAtIndex:i];
                Resource *resource = [NSEntityDescription insertNewObjectForEntityForName:@"Resource" 
                                                                   inManagedObjectContext:[self context]];
                [resource setResource:edamResource];
                resource.linked = [NSNumber numberWithBool:linked];
                
                if([resource isPic])
                {
                    NSDictionary *data;
                    if (sharedAuthKey) {
                        data = [NSDictionary dictionaryWithObjectsAndKeys:resource.guid, @"guid",
                                sharedAuthKey,@"sharedAuthKey", nil];
                    }else{
                        data = [NSDictionary dictionaryWithObjectsAndKeys:resource.guid, @"guid", nil];
                    }
                    [_needSyncResourceGuids addObject:data];
                }

                Data *data = [NSEntityDescription insertNewObjectForEntityForName:@"Data" 
                                                           inManagedObjectContext:[self context]];
                [data setData:edamResource.data];
                
                ResourceAttributes *attributes = [NSEntityDescription insertNewObjectForEntityForName:@"ResourceAttributes" 
                                                                               inManagedObjectContext:[self context]];
                [attributes setResourceAttributes:edamResource.attributes];
                
                resource.data = data;
                resource.attribute = attributes;
                [theNote addResourceObject:resource];
            }

            // 需同步笔记详情
            NSDictionary *data;
            if (sharedAuthKey) {
                data = [NSDictionary dictionaryWithObjectsAndKeys:note.guid, @"guid", note.notebookGuid, @"notebookGuid",
                        sharedAuthKey,@"sharedAuthKey", nil];
                
                NSString *url = [AppGlobal getNoteThumbnailWithShareId:linkedNotebook.shardId
                                                              noteGuid:note.guid size:160];
                
                NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:sharedAuthKey, @"auth", nil];
                
                [QueueLoader addRequest:url param:dic userInfo:data
                            reponseType:QueueBinary
                               sendType:@"post"
                                 taregt:self selector:@selector(requestFinished:userInfo:)];

            }else{
                data = [NSDictionary dictionaryWithObjectsAndKeys:note.guid, @"guid", nil];
            }
            [_needSyncNoteGuids addObject:data];
        }
    }    
}

- (void)requestFinished:(NSData *)data userInfo:(NSDictionary *)userInfo
{
    NSString *noteId = [userInfo objectForKey:@"guid"];
    
    [self saveNoteThumbnail:noteId thumbnailData:data];
}


// 初始更新时，删除在服务端已经删除的数据
- (void)deleteTrunkNotes:(NSArray *)newNotes 
                oldNotes:(NSArray *)oldNotes
{
    Note *theNote = nil;
    EDAMNote *note = nil;
    // 查找服务器上不存在，而本地存在的数据，则删除本地的数据
    for (theNote in oldNotes) {
        
        BOOL isDelete = YES;
        for (note in newNotes) 
        {
            if ([theNote.guid isEqualToString:note.guid] ||
                [theNote.dirty boolValue]) 
            {
                isDelete = NO;
                // 标签已经存在继续执行
                break;
            }
        }
        
        // 只存在在客户端，服务端不存在，则删除客户端数据
        if (isDelete) {
            [[self context] deleteObject:theNote];
        }
    }
}


// 删除中间更新时，服务器删除的数据
- (void)deleteExpungedNotes:(NSArray *)expungedNotes 
                   oldNotes:(NSArray *)oldNotes
{
    Note *theNote = nil;
    NSString   *expungedNote = nil;
    // 查找服务器上不存在，而本地存在的数据，则删除本地的数据
    for (expungedNote in expungedNotes) {
        for (theNote in oldNotes) 
        {
            if ([theNote.guid isEqualToString:expungedNote]) 
            {
                [[self context] deleteObject:theNote];
            }
        }
    }
}

// 同步服务端笔记详情
- (void)syncNotesList
{
//    for (NSDictionary *item in self.needSyncNoteGuids) {
    if ([self.needSyncNoteGuids count]>0) {
        NSDictionary *item = [self.needSyncNoteGuids objectAtIndex:0];
        NSString *guid = [item objectForKey:@"guid"];
        NSString *sharedAuthKey = [item objectForKey:@"sharedAuthKey"];
        if (sharedAuthKey) {
            NSString *notebookGuid = [item objectForKey:@"notebookGuid"];
            NSArray *list = [[ShareModel getInstance] getSharedNotebooksWithNotebookGuid:notebookGuid];
            SharedNotebook *shareNotebook = [list objectAtIndex:0];
            LinkedNotebook *linkedNotebook = [[ShareModel getInstance] getLinkedNotebookByShareKey:shareNotebook.shareKey];
            [[EvernoteShareNoteStore noteStore:linkedNotebook.noteStoreUrl] getNoteContentWithGuid :guid
                                                                            authToken:sharedAuthKey
                                                                            success:^(NSString *content){
                                                                                [self saveNoteContent:guid content:content];
                                                                                [self syncNotesList];
                                                                            }failure:^(NSError *error){
                                                                                    NSLog(@"NoteContentWithGuid %@",error);
                                                                            }];
            
        }else{
            [[EvernoteNoteStore noteStore] getNoteWithGuid:guid
                                                 authToken:sharedAuthKey
                                               withContent:YES withResourcesData:NO
                                  withResourcesRecognition:NO withResourcesAlternateData:NO
                                                   success:^(EDAMNote *note1) {
                                                       [self saveNoteContent:note1.guid content:note1.content];
                                                       [self syncNotesList];
                                                   } failure:^(NSError *error) {
                                                       
                                                   }];
        }
        [self.needSyncNoteGuids removeObjectAtIndex:0];

    }
                    
//    }
//    [self.needSyncNoteGuids removeAllObjects];
}

//- (void)syncResourceList
//{
//    return;
//    for (NSDictionary *item in self.needSyncResourceGuids) {
//        [[EvernoteNoteStore noteStore] getResourceWithGuid:[item objectForKey:@"guid"]
//                                                 authToken:[item objectForKey:@"sharedAuthKey"]
//                                                  withData:YES withRecognition:NO withAttributes:NO
//                                         withAlternateDate:NO success:^(EDAMResource *resource) {
//            [self saveResourceData:resource.guid data:resource.data.body];
//        } failure:^(NSError *error) {
//            
//        }];
//    }
//    [self.needSyncResourceGuids removeAllObjects];
//    
//    
//}

#pragma ------------- 获取附件文件数据 --

- (void)saveResourceData:(NSString *)guid data:(NSData *)body
{
    NSError *error = nil;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Resource"
                                                         inManagedObjectContext:[self context]];
    [request setEntity:entityDescription];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(guid = %@)", guid];
    [request setPredicate:pred];
    NSArray *objects = [[self context] executeFetchRequest:request error:&error];
    if (objects == nil){
        NSLog(@"There was an error!");
    }
    
    if ([objects count]>0) {
        Resource  *theResource = [objects objectAtIndex:0];
        Data *data = theResource.data;
        data.body = body;
        [theResource setData:data];
        
        [NSThread detachNewThreadSelector:@selector(onBase64Data:) toTarget:self withObject:theResource];
    }
    [request release];
    //[[self context] save:&error];
//    if (error) {
//        NSLog(@"save error %@,", error);
//    }
    
    
}
#pragma -------------


//*****************************************
//
//  客服端创建、修改
//
//*****************************************

- (void)saveNoteContent:(NSString *)guid content:(NSString *)content
{
    
    
    Note *theNote = [self getNoteByGuid:guid];
    if (theNote) {
        theNote.content = content;
//        NSError *error;
        //[[self context] save:&error];
    }
}

- (void)saveNoteThumbnail:(NSString *)guid thumbnailData:(NSData *)thumbnailData
{
    Note *theNote = [self getNoteByGuid:guid];
    if (theNote) {
        [theNote setThumbnails:thumbnailData];
//        NSError *error;
        //[[self context] save:&error];
    }
}


- (void)setNoteCommentSeq:(NSString *)guid seq:(int)seq
{
    Note *theNote = [self getNoteByGuid:guid];
    if (theNote) {
        theNote.cmtSequence = [NSNumber numberWithInt:seq];
//        NSError *error;
        //[[self context] save:&error];
    }
}

// 通过记事本id获取，记事本内笔记
- (NSArray *)getNotesByNotebookId:(NSString *)guid
{
    NSPredicate *pred;
    if (guid) {
        pred = [NSPredicate predicateWithFormat:@"(notebookGuid = %@ and active=1)", guid];
    }else {
        pred = [NSPredicate predicateWithFormat:@"(active=1 and linked=0)"];
    }
    return [self queryNotes:pred];
}


- (Note *)getNoteByGuid:(NSString *)guid
{
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(guid = %@)", guid];
    NSArray *list = [self queryNotes:pred];
    if ([list count]>0) {
        return [list objectAtIndex:0];
    }
    return nil;
}

- (NSArray *)getNoteByGuidList:(NSArray *)guids
{
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(guid in %@)", guids];
    return [self queryNotes:pred];
}

- (NSArray *)queryNotes:(NSPredicate *)pred
{
    NSError *error=nil;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Note"
                                                         inManagedObjectContext:[self context]];
    [request setEntity:entityDescription];
    
    if (pred) {
        [request setPredicate:pred];
    }
    
    NSArray *objects = [[self context] executeFetchRequest:request error:&error] ;
    
    if (objects == nil){
        NSLog(@"There was an error!");
    }
    if (error) {
        NSLog(@"error %@",error);
    }
    
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"updated" 
                                                                 ascending:NO];
    objects = [objects sortedArrayUsingDescriptors:[NSArray arrayWithObject:descriptor]];
    
    [request release];
    
    return objects;
}


// 通过资源（图片、附件）id，获取资源
- (Resource *)getResourceByGuid:(NSString *)guid
{
    NSError *error;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Resource"
                                                         inManagedObjectContext:[self context]];
    [request setEntity:entityDescription];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(guid = %@)", guid];
    [request setPredicate:pred];
    
    NSArray *objects = [[self context] executeFetchRequest:request error:&error];
    
    if (objects == nil){
        NSLog(@"There was an error!");
    }
    
    Resource *res;
    if ([objects count]>0) {
        res = [objects objectAtIndex:0];
    }
    [request release];
    
    return res;
}

// 获取图片资源未下载的
- (NSArray *)getResourceDataNullList
{
    NSError *error;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Resource"
                                                         inManagedObjectContext:[self context]];
    [request setEntity:entityDescription];
    
    NSArray *objects = [[self context] executeFetchRequest:request error:&error];
    
//    NSPredicate * filter = [NSPredicate predicateWithFormat:@"data.body = null", @""];
    
    NSMutableArray *newObjs = [NSMutableArray arrayWithCapacity:1];
    for (Resource *res in objects) {
        if (res.data.body==nil) {
            [newObjs addObject:res];
        }
    }
//    objects = [objects filteredArrayUsingPredicate:filter];  //從數組中進行過滤。
    
    if (objects == nil){
        NSLog(@"There was an error!");
    }
    
    return newObjs;
}


- (void)updateResourceData:(NSData *)data resGuid:(NSString *)resGuid
{
    Resource *resource = [self getResourceByGuid:resGuid];
    resource.data.body = data;
    
    [NSThread detachNewThreadSelector:@selector(onBase64Data:) toTarget:self withObject:resource];
    
//    NSError *error;
    //[[self context] save:&error];
}

- (void)onBase64Data:(Resource *)resource
{
    resource.data.base64 = [resource.data.body base64Encoding];
}

// 设置笔记本
- (void)setNotebook:(NSString *)noteGuid 
       notebookGuid:(NSString *)notebookGuid
{
    NSError *error;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Note"
                                                         inManagedObjectContext:[self context]];
    [request setEntity:entityDescription];
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(guid = %@)", noteGuid];
    [request setPredicate:pred];
    
    NSArray *objects = [[self context] executeFetchRequest:request error:&error];
    
    if (objects == nil){
        NSLog(@"There was an error!");
    }
    
    if ([objects count]>0) {
        NSManagedObject *theObj = [objects objectAtIndex:0];
        [theObj setValue:notebookGuid forKey:@"notebookGuid"];
        [theObj setValue:[NSNumber numberWithBool:YES] forKey:@"dirty"];
    }
    
    //[[self context] save:&error];

}

// 设置笔记本
- (void)setTags:(NSString *)noteGuid tagGuids:(NSString *)tagGuids
{
    NSError *error;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Note"
                                                         inManagedObjectContext:[self context]];
    [request setEntity:entityDescription];
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(guid = %@)", noteGuid];
    [request setPredicate:pred];
    
    NSArray *objects = [[self context] executeFetchRequest:request error:&error];
    
    if (objects == nil){
        NSLog(@"There was an error!");
    }
    
    if ([objects count]>0) {
        NSManagedObject *theObj = [objects objectAtIndex:0];
        [theObj setValue:tagGuids forKey:@"tagGuids"];
        [theObj setValue:[NSNumber numberWithBool:YES] forKey:@"dirty"];
    }
    
    //[[self context] save:&error];
    
}

// 删除笔记
- (void)deleteNote:(NSString *)guid
{
    NSError *error;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Note"
                                                         inManagedObjectContext:[self context]];
    [request setEntity:entityDescription];
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(guid = %@)", guid];
    [request setPredicate:pred];
    
    NSArray *objects = [[self context] executeFetchRequest:request error:&error];
    
    if (objects == nil){
        NSLog(@"There was an error!");
    }
    
    for (NSManagedObject *theobj in objects) {
        [[self context] deleteObject:theobj];
    }
    //[[self context] save:&error];
}


- (NSArray *)getHomePhoto:(int)num
{
    NSError *error;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Resource"
                                                         inManagedObjectContext:[self context]];
    [request setEntity:entityDescription];
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(mime = %@)",@"image/jpeg"];
    [request setPredicate:pred];
    
    NSArray *objects = [[self context] executeFetchRequest:request error:&error];
    
    if (objects == nil){
        NSLog(@"There was an error!");
    }
    
    if ([objects count]>num) {
        return [objects subarrayWithRange:NSMakeRange(0, num)];
    }else {
        return objects;
    }
}

@end
