//
//  CommandModel.h
//  Test1
//
//  Created by jenth on 12-8-21.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Comment.h"
#import "Attachment.h"

@interface CommentModel : NSObject
{
//    NSManagedObjectContext *context;
}

//@property (nonatomic, assign) NSManagedObjectContext *context;
//@property (nonatomic, retain) NSString *noteCid;
//@property (nonatomic, retain) NSString *oldAttactId;
//@property (nonatomic, retain) NSMutableArray *needUploadAttach;

+ (CommentModel *)getInstance;

//- (void)saveCommentWithNoteId:(NSString *)nid content:(NSString *)content 
//                          pid:(NSString *)pid
//                       target:(id)target action:(SEL)action;
- (void)getCommentWithNoteId:(NSString *)nid target:(id)target action:(SEL)action;
- (void)uploadFileByCmtId:(NSString *)cid fileData:(NSData *)fileData 
                      ext:(NSString *)ext name:(NSString *)name
                   target:(id)target action:(SEL)action;
- (void)addCommentList:(NSArray *)cmtList read:(BOOL)read dirty:(BOOL)dirty;
- (int)getMaxCommentId:(NSString *)nId;
- (NSDictionary *)getNewCommentNoteList;
- (NSArray *)getNewCommentsByNoteId:(NSString *)noteId;
- (void)updateAttachData:(NSData *)data aid:(int)aid;
- (NSArray *)queryCommentsByNoteId:(NSString *)noteId;
- (void)saveComment:(NSDictionary *)data;
- (void)deleteCommentWithNoteId:(NSString *)nid
                            cid:(NSString *)cid type:(NSString *)type
                         target:(id)target action:(SEL)action;
- (void)deleteComment:(NSString *)cId;
- (void)getCommentSeqWithNoteId:(NSString *)nid seq:(int)seq
                         target:(id)target action:(SEL)action;
- (void)readComment:(NSString *)cId;
- (void)setReadCommentByNoteId:(NSString *)guid;
- (void)updateReadFlagWithCId:(NSString *)cid target:(id)target action:(SEL)action;
- (NSArray *)getCommentsByNoteId:(NSString *)noteId;
- (NSArray *)getDirtyCmts;
- (void)updateCommentId:(NSString *)oldId newId:(NSString *)newId;
- (void)updateAttachId:(NSString *)oldId newId:(NSString *)newId attachUrl:(NSString *)attachUrl;

@end
