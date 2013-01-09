//
//  Resource.h
//  Test1
//
//  Created by jenth on 12-8-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "EvernoteNoteStore.h"
#import "Data.h"
#import "ResourceAttributes.h"

#define MEDIA @"//en-media"
#define MEDIA_JPEG @"image/jpeg"
#define MEDIA_GIF  @"image/gif"
#define MEDIA_PNG  @"image/png"
#define MEDIA_OSTREAM @"application/octet-stream"
#define MEDIA_PDF   @"application/pdf"
#define MEDIA_XLSX @"application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
#define MEDIA_DOCX @"application/vnd.openxmlformats-officedocument.wordprocessingml.document"
#define MEDIA_TEXT @"text/plain"

@class Data, ResourceAttributes;

@interface Resource : NSManagedObject

@property (nonatomic, retain) NSNumber * active;
@property (nonatomic, retain) NSNumber * dirty;
@property (nonatomic, retain) NSNumber * duration;
@property (nonatomic, retain) NSString * guid;
@property (nonatomic, retain) NSNumber * height;
@property (nonatomic, retain) NSNumber * linked;
@property (nonatomic, retain) NSString * mime;
@property (nonatomic, retain) NSString * noteGuid;
@property (nonatomic, retain) NSNumber * updateSequenceNum;
@property (nonatomic, retain) NSNumber * width;
@property (nonatomic, retain) ResourceAttributes *attribute;
@property (nonatomic, retain) Data *data;

- (void)setResource:(EDAMResource *)resource;
- (EDAMResource *)getEDAMResource;

- (BOOL)isPic;

@end
