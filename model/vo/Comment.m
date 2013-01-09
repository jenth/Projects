//
//  Comment.m
//  Test1
//
//  Created by jenth on 12-11-7.
//
//

#import "Comment.h"
#import "Attachment.h"


@implementation Comment

@dynamic cid;
@dynamic content;
@dynamic created;
@dynamic dirty;
@dynamic nick;
@dynamic noteId;
@dynamic parentId;
@dynamic read;
@dynamic userId;
@dynamic seq;
@dynamic attachment;


- (void)setComment:(NSDictionary *)dic read:(BOOL)read
{
    self.cid = [dic objectForKey:@"cid"];
    self.noteId = [dic objectForKey:@"nid"];
    self.userId = [dic objectForKey:@"uid"];
    self.content= [dic objectForKey:@"content"];
    self.created = [NSNumber numberWithDouble:[[dic objectForKey:@"ctime"] doubleValue]];
    self.nick = [dic objectForKey:@"nick"];
    self.parentId = [dic objectForKey:@"pid"];
    self.seq = [NSNumber numberWithInt:[[dic objectForKey:@"seq"] floatValue]];
    self.read = [NSNumber numberWithBool:read];
}


@end
