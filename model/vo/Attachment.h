//
//  Attachment.h
//  Test1
//
//  Created by jenth on 12-8-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Attachment : NSManagedObject

@property (nonatomic, retain) NSNumber * aid;
@property (nonatomic, retain) NSNumber * cid;
@property (nonatomic, retain) NSData * data;
@property (nonatomic, retain) NSString * fileName;
@property (nonatomic, retain) NSString * rid;
@property (nonatomic, retain) NSString * sourceUrl;
@property (nonatomic, retain) NSString * type;

- (void)setAttachment:(NSDictionary *)dic;
- (BOOL)isPicture;
- (BOOL)isVoice;

@end
