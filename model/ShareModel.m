//
//  ShareModel.m
//  Test1
//
//  Created by jenth on 12-8-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ShareModel.h"
#import "CoreDataManager.h"
#import "WebServiceUrl.h"
#import "WebService.h"
#import "NotebookModel.h"

@implementation ShareModel

//@synthesize context;

- (void)dealloc
{
    [super dealloc];
}

static ShareModel *instance = nil;

+ (ShareModel *)getInstance {
    
    if (instance == nil) {        
        instance = [[ShareModel alloc] init];
        
    }
    
    return instance;
}

- (id)init
{
    self = [super init];
//    context = [[CoreDataManager sharedInstance] managedObjectContext];
    return  self;
}

- (NSManagedObjectContext *)context
{
    return [[CoreDataManager sharedInstance] managedObjectContext];
}

- (void)syncShareNotebook
{
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(id = %i)", 0];
    NSArray* list = [self querySharedNotebook:pred];
    if ([list count]>0) {
        for (int i=0; i<[list count]; i++) {
            SharedNotebook *theNotebook = [list objectAtIndex:i];
            EDAMSharedNotebook *edamShareNotebook = [[EDAMSharedNotebook alloc] init];
            edamShareNotebook.email = theNotebook.email;
            edamShareNotebook.requireLogin = YES;
            edamShareNotebook.notebookModifiable = NO;
            edamShareNotebook.notebookGuid = theNotebook.notebookGuid;
            [[EvernoteNoteStore noteStore] createSharedNotebook:edamShareNotebook success:^(EDAMSharedNotebook *sharedNotebook){
                NSString *shareUrl = [NSString stringWithFormat:@"%@share/%@",[EvernoteSession sharedSession].webApiUrlPrefix,sharedNotebook.shareKey];
//                NSLog(@"sharedNotebook shareUrl:%@",shareUrl);
    //            [[ShareModel getInstance] addSharebooks:[NSArray arrayWithObject:sharedNotebook]];
                [self updateSharebook:sharedNotebook];
                
                Notebook *notebook = [[NotebookModel getInstance] getNotebookByGuid:sharedNotebook.notebookGuid];
                [[ShareModel getInstance] sendUserShareMessage:sharedNotebook.email noteName:notebook.name
                                                      shareUrl:shareUrl target:nil action:nil];
                
            } failure:^(NSError *error){}
             ];
            
            [edamShareNotebook release];

        }
    }
}

- (void)createShares:(NSArray *)emalsList notebookGuid:(NSString *)notebookGuid notebookName:(NSString *)notebookName
{
    __block int count = [emalsList count];

    for (NSString *email in emalsList) {
        email = [email stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        EDAMSharedNotebook *sharedNotebook = [[EDAMSharedNotebook alloc] init];
        sharedNotebook.email = email;
        sharedNotebook.requireLogin = YES;
        sharedNotebook.notebookModifiable = NO;
        sharedNotebook.notebookGuid = notebookGuid;

        [[ShareModel getInstance] addSharebook:sharedNotebook];
        
        [[EvernoteNoteStore noteStore] createSharedNotebook:sharedNotebook success:^(EDAMSharedNotebook *sharedNotebook){
            NSString *shareUrl = [NSString stringWithFormat:@"%@share/%@",[EvernoteSession sharedSession].webApiUrlPrefix,sharedNotebook.shareKey];
            NSLog(@"sharedNotebook shareUrl:%@",shareUrl);
//            [[ShareModel getInstance] addSharebooks:[NSArray arrayWithObject:sharedNotebook]];
            [self updateSharebook:sharedNotebook];
            [[ShareModel getInstance] sendUserShareMessage:email noteName:notebookName
                                                  shareUrl:shareUrl target:nil action:nil];
            
            count--;
            if (count==0) {
                
            }
        } failure:^(NSError *error){
            
        }];
        [sharedNotebook release];
    }
}


- (void)addSharebooks:(NSArray *)sharebooks
{
    NSError *error;
    
    NSArray *objects = [self querySharedNotebook:nil];
    
    for (EDAMSharedNotebook *edamSharedNotebook in sharebooks) {
        BOOL hasFlag = NO;
        for (SharedNotebook *theSharedNotebook in objects) {
            if (edamSharedNotebook.id == [theSharedNotebook.id intValue]) {
                hasFlag = YES;
                [theSharedNotebook setShareNotebook:edamSharedNotebook];
                break;
            }
        }
        if (!hasFlag) {
            SharedNotebook *theNew = [NSEntityDescription insertNewObjectForEntityForName:@"SharedNotebook" 
                                                              inManagedObjectContext:[self context]];
            [theNew setShareNotebook:edamSharedNotebook];
        }
    }
    
    //[[self context] save:&error];
}


- (void)addSharebook:(EDAMSharedNotebook *)edamSharedNotebook
{
    NSError *error;
    SharedNotebook *theNew = [NSEntityDescription insertNewObjectForEntityForName:@"SharedNotebook"
                                                           inManagedObjectContext:[self context]];
    [theNew setShareNotebook:edamSharedNotebook];
    
    //[[self context] save:&error];
}

- (void)updateSharebook:(EDAMSharedNotebook *)edamSharedNotebook
{
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(id = 0 and email = %@ and notebookGuid = %@)",
                                                    edamSharedNotebook.email,edamSharedNotebook.notebookGuid];
    NSArray* list = [self querySharedNotebook:pred];
    if ([list count]>0) {
        SharedNotebook *theSharedNotebook = [list objectAtIndex:0];
        [theSharedNotebook setShareNotebook:edamSharedNotebook];
        NSError *error;
        //[[self context] save:&error];
    }else{
        SharedNotebook *theNew = [NSEntityDescription insertNewObjectForEntityForName:@"SharedNotebook"
                                                               inManagedObjectContext:[self context]];
        [theNew setShareNotebook:edamSharedNotebook];
        NSError *error;
        //[[self context] save:&error];
    }
}

- (NSArray *)getSharedNotebooksWithNotebookGuid:(NSString *)guid
{
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(notebookGuid = %@)", guid];
    return [self querySharedNotebook:pred];
}

- (NSArray *)querySharedNotebook:(NSPredicate *)pred
{
    NSError *error;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"SharedNotebook"
                                                         inManagedObjectContext:[self context]];
    [request setEntity:entityDescription];
    
    if (pred) {
        [request setPredicate:pred];
    }
    
    NSArray *objects = [[self context] executeFetchRequest:request error:&error];
    
    if (objects == nil){
        NSLog(@"There was an error!");
    }
    
    return objects;
}


#pragma mark --- linkedNotebook


- (void)addLinkedList:(NSArray *)list
{
    for (int i=0; i<[list count]; i++) {
        EDAMLinkedNotebook *linked = [list objectAtIndex:i];
        [self setLinkedNoteboook:linked sharedNotebook:nil];
    }
}

- (void)setLinkedNoteboook:(EDAMLinkedNotebook *)linkedNotebook 
            sharedNotebook:(EDAMSharedNotebook *)sharedNotebook
{
    NSError *error;
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(guid = %@)", linkedNotebook.guid];
    NSArray *objects = [self queryLinkedNotebook:pred];
    
    LinkedNotebook *theLinkedNotebook;
    SharedNotebook *theSharedNotebook;
    if ([objects count]>0) {
        theLinkedNotebook = [objects objectAtIndex:0];
    }else {
        theLinkedNotebook = [NSEntityDescription insertNewObjectForEntityForName:@"LinkedNotebook" 
                                                          inManagedObjectContext:[self context]];
    }
    
    if (theLinkedNotebook.sharedNotebook==nil && sharedNotebook) {
        theSharedNotebook = [NSEntityDescription insertNewObjectForEntityForName:@"SharedNotebook"
                                                          inManagedObjectContext:[self context]];
        [theLinkedNotebook setSharedNotebook:theSharedNotebook];
    }
    
    if (linkedNotebook.updateSequenceNum>[theLinkedNotebook.updateSequenceNum intValue]) {
        [theLinkedNotebook setLinkedNotebook:linkedNotebook];
        if(theLinkedNotebook.sharedNotebook) [theLinkedNotebook.sharedNotebook setShareNotebook:sharedNotebook];
    }
    
    //[[self context] save:&error];
}

- (NSArray *)queryLinkedNotebook:(NSPredicate *)pred
{
    NSError *error;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"LinkedNotebook"
                                                         inManagedObjectContext:[self context]];
    [request setEntity:entityDescription];
    
    if (pred) {
        [request setPredicate:pred];
    }
    
    NSArray *objects = [[self context] executeFetchRequest:request error:&error];
    
    if (objects == nil){
        NSLog(@"There was an error!");
    }

    return objects;
}

- (NSArray *)getLinkedNotebook
{
    return [self queryLinkedNotebook:nil];
}

- (LinkedNotebook *)getLinkedNotebookByShareKey:(NSString *)shareKey
{
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(shareKey = %@)", shareKey];
    NSArray *list = [self queryLinkedNotebook:pred];
    if ([list count]>0) {
        return [list objectAtIndex:0];
    }
    return nil;
}

/*****
 POST参数：
 email  要发送的邮箱；
 note_name 共享的笔记名称
 url     evernote共享笔记链接
 *******/

- (void)sendUserShareMessage:(NSString *)email noteName:(NSString *)noteName 
                    shareUrl:(NSString *)shareUrl
                      target:(id)target action:(SEL)action
{
    NSString *url = [WebServiceUrl getUrl:@"Noteshare"];

    NSMutableDictionary *data = [NSMutableDictionary dictionaryWithCapacity:3];
    [data setValue:email forKey:@"email"];
    [data setValue:noteName forKey:@"note_name"];
    [data setValue:shareUrl forKey:@"url"];
    
    [WebService requestWithUrl:url
                      postData:data
                        target:target action:action];
}

@end
