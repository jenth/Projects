//
//  CommentSubmitProxy.m
//  Test1
//
//  Created by jenth on 12-11-17.
//
//

#import "CommentSubmitProxy.h"
#import "WebServiceUrl.h"
#import "EvernoteNoteStore.h"
#import "WebService.h"
#import "UserModel.h"
#import "CommentModel.h"

@implementation CommentSubmitProxy


@synthesize noteCid=_noteCid, needUploadAttach=_needUploadAttach;
@synthesize oldAttactId=_oldAttactId;

- (id)initWithData:(NSDictionary *)data
{
    self = [super init];
    
    [self saveComment:data];
    
    return self;
}

/******
 POST参数：content 文字内容，可以为””；
 nid  被评论的笔记ID
 uid   留言用户的evernoteID
 nick  留言用户昵称
 *******/
- (void)saveCommentWithNoteId:(NSString *)nid content:(NSString *)content
                          pid:(NSString *)pid
                       target:(id)target action:(SEL)action
{
    NSString *url = [WebServiceUrl getUrl:@"SaveComment"];
    
    EDAMUser *user = [UserModel getInstance].user;
    NSMutableDictionary *data = [NSMutableDictionary dictionaryWithCapacity:3];
    [data setValue:nid forKey:@"nid"];
    [data setValue:content forKey:@"content"];
    [data setValue:pid forKey:@"pid"];
    [data setValue:[NSString stringWithFormat:@"%i",user.id] forKey:@"uid"];
    [data setValue:user.username forKey:@"nick"];
    
    [WebService requestWithUrl:url
                      postData:data
                        target:target action:action];
}

- (void)saveComment:(NSDictionary *)data
{
    self.needUploadAttach = [data objectForKey:@"attachs"];
    self.noteCid = [data objectForKey:@"cid"];
    [self saveCommentWithNoteId:[data objectForKey:@"nid"]
                        content:[data objectForKey:@"content"]
                            pid:[data objectForKey:@"pid"]
                         target:self action:@selector(onSaveComment:)];
}

- (void)onSaveComment:(NSDictionary *)data
{
    if (data && [[data objectForKey:@"status"] boolValue]) {
        NSString *cid = [[data objectForKey:@"data"] objectForKey:@"cid"];
        [[CommentModel getInstance] updateCommentId:self.noteCid newId:cid];
        self.noteCid = cid;
        [self uploadFile];
    }
}

// 上传图片
- (void)uploadFile
{
    if ([self.needUploadAttach count]>0) {
        NSDictionary *item = [self.needUploadAttach objectAtIndex:0];
        self.oldAttactId = [item objectForKey:@"id"];
        
        [[CommentModel getInstance] uploadFileByCmtId:self.noteCid
                       fileData:[item objectForKey:@"data"]
                            ext:[item objectForKey:@"type"]
                           name:[item objectForKey:@"fileName"]
                         target:self action:@selector(onUploadFile:)];
        
        [self.needUploadAttach removeObjectAtIndex:0];
    }else{
        [[CommentModel getInstance] updateReadFlagWithCId:self.noteCid target:nil action:nil];
    }
}

- (void)onUploadFile:(NSDictionary *)data
{
    if (data && [[data objectForKey:@"status"] boolValue]) {
        NSString *aid = [[data objectForKey:@"data"] objectForKey:@"aid"];
        NSString *attachUrl = [[data objectForKey:@"data"] objectForKey:@"attach"];
        [[CommentModel getInstance] updateAttachId:self.oldAttactId newId:aid attachUrl:attachUrl];
        
    }else {
        NSLog(@"%@",data);
    }
    [self uploadFile];
}

@end
