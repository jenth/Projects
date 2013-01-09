//
//  Attachment.m
//  Test1
//
//  Created by jenth on 12-8-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "Attachment.h"


@implementation Attachment

@dynamic aid;
@dynamic cid;
@dynamic data;
@dynamic fileName;
@dynamic rid;
@dynamic sourceUrl;
@dynamic type;

- (void)setAttachment:(NSDictionary *)dic
{
    self.aid = [dic objectForKey:@"id"];
    self.sourceUrl = [dic objectForKey:@"attach"];
    self.type = [dic objectForKey:@"type"];
    self.fileName = [dic objectForKey:@"fileName"];
    self.data = [dic objectForKey:@"data"];
}

- (BOOL)isPicture
{
    if ([self.type isEqualToString:@"jpg"] ||
        [self.type isEqualToString:@"gif"] ||
        [self.type isEqualToString:@"png"]) {
        return YES;
    }else {
        return NO;
    }
}

- (BOOL)isVoice
{
    if ([self.type isEqualToString:@"caf"]||
        [self.type isEqualToString:@"wav"]||
        [self.type isEqualToString:@"mp3"]) {
        return YES;
    }else {
        return NO;
    }
}


@end
