//
//  Comment.h
//  Test1
//
//  Created by jenth on 12-11-7.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Attachment;

@interface Comment : NSManagedObject

@property (nonatomic, retain) NSNumber * cid;
@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSNumber * created;
@property (nonatomic, retain) NSNumber * dirty;
@property (nonatomic, retain) NSString * nick;
@property (nonatomic, retain) NSString * noteId;
@property (nonatomic, retain) NSNumber * parentId;
@property (nonatomic, retain) NSNumber * read;
@property (nonatomic, retain) NSString * userId;
@property (nonatomic, retain) NSNumber * seq;
@property (nonatomic, retain) NSSet *attachment;
@end

@interface Comment (CoreDataGeneratedAccessors)

- (void)addAttachmentObject:(Attachment *)value;
- (void)removeAttachmentObject:(Attachment *)value;
- (void)addAttachment:(NSSet *)values;
- (void)removeAttachment:(NSSet *)values;

- (void)setComment:(NSDictionary *)dic read:(BOOL)read;

@end
