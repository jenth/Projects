//
//  CommandModel.m
//  Test1
//
//  Created by jenth on 12-8-21.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CommentModel.h"
#import "WebServiceUrl.h"
#import "WebService.h"
#import "EvernoteUserStore.h"
#import "CoreDataManager.h"
#import "Note.h"
#import "UserModel.h"
#import "CommentSubmitProxy.h"

@implementation CommentModel

//@synthesize context;
//@synthesize noteCid=_noteCid, needUploadAttach=_needUploadAttach;
//@synthesize oldAttactId=_oldAttactId;

static CommentModel *instance = nil;

+ (CommentModel *)getInstance {
    
    if (instance == nil) {        
        instance = [[CommentModel alloc] init];
    }
    
    return instance;
}

- (id)init
{
    self = [super init];
    
//    self.context = [[CoreDataManager sharedInstance] managedObjectContext];
    
    return self;
}

- (NSManagedObjectContext *)context
{
    return [[CoreDataManager sharedInstance] managedObjectContext];
}

#pragma mark ------请求后台API-------------- 

- (void)saveComment:(NSDictionary *)data
{
    [[[CommentSubmitProxy alloc] initWithData:data] autorelease];
}

/******
 POST参数：nid  被评论的笔记ID
 uid   留言用户的evernoteID
 *******/
- (void)getCommentWithNoteId:(NSString *)nid 
                      target:(id)target action:(SEL)action
{
    NSString *url = [WebServiceUrl getUrl:@"GetComment"];
    
    EDAMUser *user = [UserModel getInstance].user;
    NSMutableDictionary *data = [NSMutableDictionary dictionaryWithCapacity:3];
    [data setValue:nid forKey:@"nid"];
    [data setValue:[NSString stringWithFormat:@"%i",user.id] forKey:@"uid"];
    int maxCId = [self getMaxCommentId:nid];
    [data setValue:[NSNumber numberWithInt:maxCId] forKey:@"lastId"];
    
    [WebService requestWithUrl:url
                      postData:data
                        target:target action:action];
}



/******
 GET参数：cid  对应的留言的ID
 uid  留言用户的ID
 ext  上传文件的类型（后缀名）
 POST：文件流
 *******/
- (void)uploadFileByCmtId:(NSString *)cid fileData:(NSData *)fileData 
                      ext:(NSString *)ext name:(NSString *)name
                   target:(id)target action:(SEL)action
{
    EDAMUser *user = [UserModel getInstance].user;
    NSMutableString *url = [NSMutableString stringWithString:[WebServiceUrl getUrl:@"FileSave"]];
    [url appendFormat:@"?cid=%@", cid],
    [url appendFormat:@"&uid=%i", user.id];
    [url appendFormat:@"&ext=%@", ext];
    [url appendFormat:@"&name=%@", name];
    
    [WebService requestWithUrl:url
                      postData:fileData
                        target:target action:action];
}

/******* 删除评论
 nid  被评论的笔记ID  “,”逗号隔开表示读取多个笔记的留言
 uid   留言用户的evernoteID或者该笔记的拥有者evernoteID
 cid  要删除的留言ID；
 若是笔记的拥有者要删除其他留言用户的留言ID，则还需带上加密参数：
 type  加密参数，md5(nid+key+uid+cid)   key值为：evernoteVgJX2D
 ***********/
- (void)deleteCommentWithNoteId:(NSString *)nid
                      cid:(NSString *)cid type:(NSString *)type
                   target:(id)target action:(SEL)action
{
    NSString *url = [WebServiceUrl getUrl:@"CommentCdel"];
    
    EDAMUser *user = [UserModel getInstance].user;
    NSMutableDictionary *data = [NSMutableDictionary dictionaryWithCapacity:3];
    [data setValue:nid forKey:@"nid"];
    [data setValue:[NSString stringWithFormat:@"%i",user.id] forKey:@"uid"];
    [data setValue:cid forKey:@"cid"];
    
    [WebService requestWithUrl:url
                      postData:data
                        target:target action:action];    
}

/****
 POST参数：uid  当前用户EVERNOTE_ID
 seq  操作序号 返回结果为大于该序号的数据
 ****/
- (void)getCommentSeqWithNoteId:(NSString *)nid seq:(int)seq
                         target:(id)target action:(SEL)action
{
    NSString *url = [WebServiceUrl getUrl:@"CommentSeq"];
    
    EDAMUser *user = [UserModel getInstance].user;
    NSMutableDictionary *data = [NSMutableDictionary dictionaryWithCapacity:3];
    [data setValue:nid forKey:@"nid"];
    [data setValue:[NSString stringWithFormat:@"%i",user.id] forKey:@"uid"];
    [data setValue:[NSNumber numberWithInt:seq] forKey:@"seq"];
    [WebService requestWithUrl:url
                      postData:data
                        target:target action:action];
}


- (void)updateReadFlagWithCId:(NSString *)cid target:(id)target action:(SEL)action
{
    NSString *url = [WebServiceUrl getUrl:@"FlagRead"];
    
    EDAMUser *user = [UserModel getInstance].user;
    NSMutableDictionary *data = [NSMutableDictionary dictionaryWithCapacity:2];
    [data setValue:cid forKey:@"cids"];
    [data setValue:[NSString stringWithFormat:@"%i",user.id] forKey:@"uid"];
    [WebService requestWithUrl:url
                      postData:data
                        target:target action:action];
}


#pragma mark ------请求后台API END --------------

- (void)updateCommentId:(NSString *)oldId newId:(NSString *)newId
{
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(cid=%@)", oldId];
    NSArray *list = [self queryComment:pred];
    if ([list count]>0) {
        Comment *obj = [list objectAtIndex:0];
        obj.cid = [NSNumber numberWithInt:[newId intValue]];
        obj.dirty = [NSNumber numberWithBool:YES];
        // NSError *error;
        //[[self context] save:&error];
    }
}

- (void)updateAttachId:(NSString *)oldId newId:(NSString *)newId attachUrl:(NSString *)attachUrl
{
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(aid=%@)", oldId];
    NSArray *list = [self queryAttachment:pred];
    if ([list count]>0) {
        Attachment *obj = [list objectAtIndex:0];
        obj.aid = [NSNumber numberWithInt:[newId intValue]];
        obj.sourceUrl = attachUrl;
        // NSError *error;
        //[[self context] save:&error];
    }
}

- (void)deleteComment:(NSString *)cId
{
    NSError *error;
    [[self context] save:&error];
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(cid=%@)", cId];
    NSArray *list = [self queryComment:pred];
    if ([list count]>0) {
        [[self context] deleteObject:[list objectAtIndex:0]];
        // NSError *error;
        //[[self context] save:&error];
    }
}

- (void)readComment:(NSString *)cId
{
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(cid=%@)", cId];
    NSArray *list = [self queryComment:pred];
    if ([list count]>0) {
        Comment *cmt = [list objectAtIndex:0];
        cmt.read = [NSNumber numberWithInt:1];
        // NSError *error;
        //[[self context] save:&error];
    }
}

- (void)setReadCommentByNoteId:(NSString *)guid
{
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(noteId=%@ AND read=0)", guid];
    NSArray *list = [self queryComment:pred];
    if ([list count]>0) {
        NSMutableArray *ids = [NSMutableArray arrayWithCapacity:[list count]];
        for (Comment *cmt in list) {
            cmt.read = [NSNumber numberWithBool:YES];
            [ids addObject:cmt.cid];
        }
        NSString *cids = [ids componentsJoinedByString:@","];
        // NSError *error;
        //[[self context] save:&error];
    
        [self updateReadFlagWithCId:cids target:self action:@selector(setReadComplete:)];
        
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:guid,@"guid", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"changeNoteCmt" object:nil
                                                          userInfo:userInfo];
    }
}

- (void)setReadComplete:(NSDictionary *)data
{
//    NSLog(@"set read %@", data);
}

// 获取笔记的留言
- (NSArray *)queryCommentsByNoteId:(NSString *)noteId
{
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(noteId=%@)", noteId];
    return [self queryComment:pred];
}

// 查询留言
- (NSArray *)queryComment:(NSPredicate *)pred
{
    NSError *error;
    
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Comment"
                                                         inManagedObjectContext:[self context]];
    [request setEntity:entityDescription];
    
    if (pred) {
        [request setPredicate:pred];
    }
    
    NSArray *objects = [[self context] executeFetchRequest:request error:&error];
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"created" 
                                                                 ascending:NO];
    objects = [objects sortedArrayUsingDescriptors:[NSArray arrayWithObject:descriptor]];
    
    if (objects == nil){
        NSLog(@"There was an error!");
    }
    
    return objects;
}

// 查询附件
- (NSArray *)queryAttachment:(NSPredicate *)pred
{
    NSError *error;
    
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Attachment"
                                                         inManagedObjectContext:[self context]];
    [request setEntity:entityDescription];
    
    if (pred) {
        [request setPredicate:pred];
    }
    
    NSArray *objects = [[self context] executeFetchRequest:request error:&error];
    
    if (objects == nil){
        NSLog(@"There was an error!");
    }
    
    return objects;
}


- (void)updateAttachData:(NSData *)data aid:(int)aid
{
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(aid=%i)", aid];
    NSArray *list = [self queryAttachment:pred];
    if ([list count]>0) {
        Attachment *attach = [list objectAtIndex:0];
        attach.data = data;
        // NSError *error;
        //[[self context] save:&error];
    }
}

//添加留言列表数据到数据库
- (void)addCommentList:(NSArray *)cmtList read:(BOOL)read dirty:(BOOL)dirty
{
 
    for (int i=0; i<[cmtList count]; i++) {
        NSDictionary *data = [cmtList objectAtIndex:i];
        
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"(cid = %@)", [data objectForKey:@"cid"]];
        NSArray *objects = [self queryComment:pred];
        
        Comment *cmt;
        if ([objects count]==0) {
            cmt = (Comment*)[NSEntityDescription insertNewObjectForEntityForName:@"Comment" 
                                                          inManagedObjectContext:[self context]];
            [cmt setComment:data read:read];
            cmt.dirty = [NSNumber numberWithBool:dirty];
            
            NSArray *attachs = [data objectForKey:@"attachs"];
            for (NSDictionary *item in attachs) {
                Attachment *attchment = (Attachment*)[NSEntityDescription insertNewObjectForEntityForName:@"Attachment" 
                                                                                   inManagedObjectContext:[self context]];
                [attchment setAttachment:item];
                [cmt addAttachmentObject:attchment];
            }
        }
    }
    
    // NSError *error;
    //[[self context] save:&error];
}


// 获取本地获取的评论最大id, 用于更新服务端新评论
- (int)getMaxCommentId:(NSString *)nId
{
    NSError *error;
    
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Comment"
                                                         inManagedObjectContext:[self context]];
    [request setEntity:entityDescription];
    
    if (nId) {
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"(noteId = %@)", nId];
        [request setPredicate:pred]; 
    }
    
    NSArray *objects = [[self context] executeFetchRequest:request error:&error];
    if (objects == nil){
        NSLog(@"There was an error!");
    }

    NSNumber *num = [objects valueForKeyPath:@"@max.cid"];
    return [num intValue];
}

// 获取未读留言
- (NSDictionary *)getNewCommentNoteList
{
    NSError *error=nil;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Comment"
                                                         inManagedObjectContext:[self context]];
    [request setEntity:entityDescription];
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(read = 0)"];
    [request setPredicate:pred];
    NSArray *objects = [[self context] executeFetchRequest:request error:&error];
    
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"created" 
                                                                 ascending:YES];
    objects = [objects sortedArrayUsingDescriptors:[NSArray arrayWithObject:descriptor]];
    
    if(error) NSLog(@"error %@",error);
    if (objects == nil){
        NSLog(@"There was an error!");
    }

    int myNoteCommentNum = 0;
    int shareNoteCommentNum = 0;
    NSMutableArray *myNoteComment = [NSMutableArray arrayWithCapacity:1];
    NSMutableArray *shareNoteComment = [NSMutableArray arrayWithCapacity:1];
    NSMutableArray *allNoteComment = [NSMutableArray arrayWithCapacity:1];
    
    for (Comment *comment in objects) {
        NSEntityDescription *noteEntityDescription = [NSEntityDescription entityForName:@"Note"
                                                             inManagedObjectContext:[self context]];
        [request setEntity:noteEntityDescription];
        NSPredicate *notePred = [NSPredicate predicateWithFormat:@"(guid = %@ )", comment.noteId];
        [request setPredicate:notePred];
        NSArray *notes = [[self context] executeFetchRequest:request error:&error];
        if ([notes count]>0) {
            Note *note = [notes objectAtIndex:0];
            if ([note.linked intValue]==0) {
                myNoteCommentNum += 1;
                if (![myNoteComment containsObject:note]) {
                    [myNoteComment addObject:note];
                }
            }else {
                shareNoteCommentNum += 1;
                if (![shareNoteComment containsObject:note]) {
                    [shareNoteComment addObject:note];
                }
            }
            
            if (![allNoteComment containsObject:note]) {
                [allNoteComment addObject:note];
            }
        }
    }
    
    [request release];
    
    NSMutableDictionary *data = [NSMutableDictionary dictionaryWithCapacity:4];
    [data setObject:[NSNumber numberWithInt:myNoteCommentNum] forKey:@"myNewCmtNum"];
    [data setObject:[NSNumber numberWithInt:shareNoteCommentNum] forKey:@"shareNewCmtNum"];
    [data setObject:myNoteComment forKey:@"myNewCmtNote"];
    [data setObject:shareNoteComment forKey:@"shareNewCmtNote"];
    [data setObject:allNoteComment forKey:@"allNoteComment"];
    
    return data;
}

// 查询制定笔记的新留言
- (NSArray *)getNewCommentsByNoteId:(NSString *)noteId
{
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(noteId=%@ AND read=0)", noteId];
    return [self queryComment:pred];
}

// 查询制定笔记的新留言
- (NSArray *)getCommentsByNoteId:(NSString *)noteId
{
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(noteId=%@)", noteId];
    return [self queryComment:pred];
}

- (NSArray *)getDirtyCmts
{
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(dirty=%i)", 0];
    return [self queryComment:pred];
}

@end
