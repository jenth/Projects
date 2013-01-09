//
//  NoteModel.m
//  Test1
//
//  Created by jenth on 12-5-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "TagModel.h"
#import "AppDelegate.h"
#import "CoreDataManager.h"
#import "Tag.h"
#import "Note.h"


@implementation TagModel

@synthesize tagEdit;


- (void)dealloc
{
//    [tagsList release];
    
    [super dealloc];
}

static TagModel *instance = nil;

+ (TagModel *)getInstance {
    
    if (instance == nil) {        
        instance = [[TagModel alloc] init];
        
    }

    return instance;
}

- (id)init
{
    self = [super init];
//    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
//    context = [[CoreDataManager sharedInstance] managedObjectContext];
    tagEdit = NO;
    return  self;
}

- (NSManagedObjectContext *)context
{
    return [[CoreDataManager sharedInstance] managedObjectContext];
}

//*****************************************
//
//  同步标签
//
//*****************************************

// 同步Tag表
- (void)setTagsList:(NSArray *)tagsList 
       expungedTags:(NSArray *)expungedTags 
           isUpdate:(BOOL)isUpdate 
             linked:(BOOL)linked
{
    NSError *error;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Tag"
                                                         inManagedObjectContext:[self context]];
    [request setEntity:entityDescription];
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(linked = %i)", linked];
    [request setPredicate:pred];
    
    NSArray *objects = [[self context] executeFetchRequest:request error:&error];
    
    if (objects == nil){
        NSLog(@"There was an error!");
    }
    
    [self addAndEditTags:tagsList 
                 oldTags:objects 
                  linked:linked];
    
    // 删除服务器同步下，删除的数据
    if (isUpdate) // 中间更新数据，服务器有返回已经删除的数据
    { 
        [self deleteExpungedTags:expungedTags 
                         oldTags:objects];
    }
    
    /*** 本地不编辑笔记，不需要比对本地的数据
     暂时屏蔽
    else // 初始更新，比对服务器返回的数据和客服端的比对
    { 
        [self deleteTrunkTags:tagsList 
                      oldTags:objects]; 
    }
     ********/

    // 提交客户端新建的到服务端
//    [self uploadTags:objects];
    
    [request release];
    //[[self context] save:&error];

}


// 添加编辑标签
- (void)addAndEditTags:(NSArray *)newTags 
               oldTags:(NSArray *)oldTags 
                linked:(BOOL)linked
{
    Tag *theTag = nil;
    EDAMTag *tag = nil;
    
    for (tag in newTags) 
    {
        BOOL isNew = YES;
        
        for (theTag in oldTags) 
        {
            
            // 标签name相同且guide不同
            if ([tag.name isEqualToString:theTag.name] &&
                ![tag.guid isEqualToString:theTag.guid]) {
                
                // 本地做了修改，则合并处理或解决冲突
                if (theTag.dirty) 
                {
                    NSString *newName = [NSString stringWithFormat:@"%@(2)",
                                         [theTag valueForKey:@"name"]];
                    theTag.name = newName;
                    theTag.dirty= NO;
                }
                else // 
                {
                    NSString *newName = [NSString stringWithFormat:@"%@(2)",
                                         [theTag valueForKey:@"name"]];
                    theTag.name = newName;
                }
            }
            // 同一个标签
            else if ([tag.guid isEqualToString:theTag.guid]) 
            {
                // 更新时间相同
                if (tag.updateSequenceNum==[theTag.updateSequenceNum intValue]) 
                {
                    // 本地做了修改, 则提交最新修改到服务器
                    if (theTag.dirty) {
                        
                    }
                    
                }
                // 服务器做了最新修改
                else if (tag.updateSequenceNum >[theTag.updateSequenceNum intValue]) 
                {
                    // 本地也做了修改， 则合并处理或解决冲突
                    if (theTag.dirty) 
                    {
                        theTag.name = tag.name;
                        theTag.parentGuid = tag.parentGuid;
                        theTag.updateSequenceNum = [NSNumber numberWithInt:tag.updateSequenceNum];
                        theTag.dirty = NO;
                    }
                    else // 本地没做修改，则更新服务数据到客户端
                    {
                        theTag.name = tag.name;
                        theTag.parentGuid = tag.parentGuid;
                        theTag.updateSequenceNum = [NSNumber numberWithInt:tag.updateSequenceNum];
                    }
                }
                
                isNew = NO;
                // 标签已经存在继续执行
                break;
            }
        }
        
        // If a tag exists in the server’s list, but not in the client, add to the client DB
        if (isNew) {
            theTag = [NSEntityDescription insertNewObjectForEntityForName:@"Tag" 
                                                   inManagedObjectContext:[self context]];
            theTag.guid = tag.guid;
            theTag.name = tag.name;
            theTag.parentGuid = tag.parentGuid;
            theTag.updateSequenceNum = [NSNumber numberWithInt:tag.updateSequenceNum];
            theTag.dirty = [NSNumber numberWithBool:NO];
            theTag.linked= [NSNumber numberWithBool:linked];
        }
    }    
}

// 初始更新时，删除在服务端已经删除的数据
- (void)deleteTrunkTags:(NSArray *)newTags 
                 oldTags:(NSArray *)oldTags
{
    Tag *theTag = nil;
    EDAMTag *tag = nil;
    // 查找服务器上不存在，而本地存在的数据，则删除本地的数据
    for (theTag in oldTags) {
        
        BOOL isDelete = YES;
        for (tag in newTags) 
        {
            if ([theTag.guid isEqualToString:tag.guid] ||
                [theTag.dirty boolValue]) 
            {
                isDelete = NO;
                // 标签已经存在继续执行
                break;
            }
        }
        
        // 只存在在客户端，服务端不存在，则删除客户端数据
        if (isDelete) {
            [[self context] deleteObject:theTag];
        }
    }
}


// 删除中间更新时，服务器删除的数据
- (void)deleteExpungedTags:(NSArray *)expungedTags 
                   oldTags:(NSArray *)oldTags
{
    Tag *theTag = nil;
    NSString   *expungedTag = nil;
    // 查找服务器上不存在，而本地存在的数据，则删除本地的数据
    for (expungedTag in expungedTags) {
        for (theTag in oldTags) 
        {
            if ([theTag.guid isEqualToString:expungedTag]) 
            {
                [[self context] deleteObject:theTag];
            }
        }
    }
}

// 提交客户端新建的信息
- (void)uploadTags:(NSArray *)clientTags 
{
//    Tag *theTag = nil;
//    EDAMTag *tag;
//    for (theTag in clientTags) {
//        if (theTag.dirty) {
//            tag = [[EDAMTag alloc] init];
//            tag.name = theTag.name;
//            tag.parentGuid = theTag.parentGuid;
//            if ([theTag.guid rangeOfString:@"l_"].location != NSNotFound) {
//                tag.guid = nil;
//                EDAMTag *newTag = [[Evernote sharedInstance] createTag:tag];
//                theTag.guid = newTag.guid;
//                theTag.updateSequenceNum = [NSNumber numberWithInt:newTag.updateSequenceNum];
//                theTag.dirty = NO;
//            }else {
//                tag.guid = theTag.guid;
//                int USN = [[Evernote sharedInstance] updateTag:tag];
//                theTag.updateSequenceNum = [NSNumber numberWithInt:USN];
//                theTag.dirty = NO;
//            }
//            [tag release];
//        }
//    }
}



//*****************************************
//
//  客服端创建、修改标签
//
//*****************************************
- (void)createTag:(EDAMTag *)newTag
{
//    EDAMTag *newTag = [[Evernote sharedInstance] createTag:tag];
    
    NSError *error;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Tag"
                                                         inManagedObjectContext:[self context]];
    [request setEntity:entityDescription];
    
    NSArray *objects = [[self context] executeFetchRequest:request error:&error];
    
    if (objects == nil){
        NSLog(@"There was an error!");
    }

    Tag *theTag = [NSEntityDescription insertNewObjectForEntityForName:@"Tag" 
                                                            inManagedObjectContext:[self context]];
    [theTag setValue:newTag.guid forKey:@"guid"];
    [theTag setValue:newTag.name forKey:@"name"];
    [theTag setValue:newTag.parentGuid forKey:@"parentGuid"];
    [theTag setValue:[NSNumber numberWithInt:newTag.updateSequenceNum ] 
              forKey:@"updateSequenceNum"];
    [theTag setValue:[NSNumber numberWithBool:YES] forKey:@"dirty"];
    
    [request release];
    //[[self context] save:&error];
}

- (void)updateTag:(EDAMTag *)tag
{
//    int USN = [[Evernote sharedInstance] updateTag:tag];
//    
//    NSError *error;
//    
//    NSFetchRequest *request = [[NSFetchRequest alloc] init];
//    
//    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Tag"
//                                                         inManagedObjectContext:context];
//    [request setEntity:entityDescription];
//    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(guid = %@)", tag.guid];
//    [request setPredicate:pred];
//    
//    NSArray *objects = [context executeFetchRequest:request error:&error];
//    
//    if (objects == nil){
//        NSLog(@"There was an error!");
//    }
//    
//    NSManagedObject *theTag = [NSEntityDescription insertNewObjectForEntityForName:@"Tag" 
//                                                            inManagedObjectContext:context];
//    [theTag setValue:tag.name forKey:@"name"];
//    [theTag setValue:tag.parentGuid forKey:@"parentGuid"];
//    [theTag setValue:[NSNumber numberWithInt:USN] 
//              forKey:@"updateSequenceNum"];
//    [theTag setValue:[NSNumber numberWithBool:NO] forKey:@"dirty"];
//    
//    [request release];
//    [context save:&error];
}

//
- (NSArray *)getTagsByGuids:(NSArray *)guids
{
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(guid in %@)", guids];
    NSArray *notebooks = [self searchTagList:pred];
    return notebooks;
}

- (NSArray *)getTagsList
{
    return [self searchTagList:nil];
}


// 查询标签
- (NSArray *)searchTagList:(NSPredicate *)pred
{
    NSError *error;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Tag"
                                                         inManagedObjectContext:[self context]];
    [request setEntity:entityDescription];
    
    if (pred) {
        [request setPredicate:pred];
    }
    
    NSArray *objects = [[self context] executeFetchRequest:request error:&error];
    
//    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"serviceUpdated" 
//                                                                 ascending:NO];
//    objects = [objects sortedArrayUsingDescriptors:[NSArray arrayWithObject:descriptor]];
    
    if (objects == nil){
        NSLog(@"There was an error!");
    }
    
    NSMutableArray *tags = [[NSMutableArray alloc] initWithCapacity:1];
    EDAMTag *tag;
    for(NSManagedObject *theTag in objects)
    {
        tag = [[EDAMTag alloc] init];
        tag.guid = [theTag valueForKey:@"guid"];
        tag.name = [theTag valueForKey:@"name"];
        tag.parentGuid = [theTag valueForKey:@"parentGuid"];
        tag.updateSequenceNum = [[theTag valueForKey:@"updateSequenceNum"] intValue];
        [tags addObject:tag];
        [tag release];
    }
    
    NSArray *tagsArr = [NSArray arrayWithArray:tags];
    [tags release];
    
    return tagsArr;
    
}


@end
