//
//  NoteCmtSeq.h
//  Test1
//
//  Created by jenth on 12-11-7.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface NoteCmtSeq : NSManagedObject

@property (nonatomic, retain) NSString * noteGuid;
@property (nonatomic, retain) NSNumber * seq;

@end
