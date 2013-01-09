//
//  CommentSubmitProxy.h
//  Test1
//
//  Created by jenth on 12-11-17.
//
//

#import <Foundation/Foundation.h>

@interface CommentSubmitProxy : NSObject

@property (nonatomic, retain) NSString *noteCid;
@property (nonatomic, retain) NSString *oldAttactId;
@property (nonatomic, retain) NSMutableArray *needUploadAttach;

- (id)initWithData:(NSDictionary *)data;

@end
