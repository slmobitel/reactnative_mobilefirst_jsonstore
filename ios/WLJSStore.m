//
//  WLJSStore.m
//  MobitelFuelcard
//
//  Created by Mobitel on 5/30/18.
//  Copyright © 2018 Facebook. All rights reserved.
//

#import "WLJSStore.h"

@interface WLJSStore ()

@end

@implementation WLJSStore
RCT_EXPORT_MODULE();
NSString * const  JSONSTORE_SUCCESS=@"Success";
NSString * const  JSONSTORE_CREATE_ERROR=@"jsonstore creation failed";
NSString * const  JSONSTORE_ADDITION_ERROR=@"jsonstore addition failed";
NSString * const  JSONSTORE_FIND_ERROR=@"jsonstore finding failed";
NSString * const  JSONSTORE_REPLACE_ERROR=@"jsonstore replacing failed";
NSString * const  JSONSTORE_REMOVE_ERROR=@"jsonstore removing failed";
NSString * const  JSONSTORE_REMOVE_COLLECTION_ERROR=@"jsonstore collection removing failed";
NSString * const  JSONSTORE_DESTROY_ALL_ERROR=@"jsonstore destroy failed";
NSString * const JSONSTORE_FIND_DIRTY_ERROR = @"jsonstore find dirty documents failed";

-(NSMutableDictionary *) sendErrorDetails:(NSString *) methodname error:(NSString *)error occuredEvent:(NSString *)occuredevent{
    NSMutableDictionary* error_data = [NSMutableDictionary new];
    [error_data setObject:methodname forKey:@"method"];
    [error_data setObject:error forKey:@"error"];
    [error_data setObject:occuredevent forKey:@"event"];
    return error_data;
}

-(JSONStoreQueryPart*) getSearchFields: (NSDictionary *)keysandvalues{
    JSONStoreQueryPart *query = [[JSONStoreQueryPart alloc] init];
    NSEnumerator *enumerator = [keysandvalues keyEnumerator];
    id key;
    while((key = [enumerator nextObject])){
        [query searchField:key equal:[keysandvalues objectForKey:key]];
    }
    return query;
}

-(JSONStoreCollection*) setCollection:(JSONStoreCollection *) collection forFields: (NSDictionary *) fieldsandtypes{
    NSEnumerator *enumerator = [fieldsandtypes keyEnumerator];
    id key;
    while((key = [enumerator nextObject])){
        NSString *className = NSStringFromClass ([[fieldsandtypes objectForKey:key] class]);
        NSLog(@"key %@ type %@",key,[fieldsandtypes objectForKey:key]);
        NSLog(@"bool value %i",[[fieldsandtypes objectForKey:key] boolValue]);

        //
        if([[fieldsandtypes objectForKey:key] isKindOfClass: [NSString class]]){
            NSLog(@"key type s %@",[[fieldsandtypes objectForKey:key] class]);
            [collection setSearchField:key withType:JSONStore_String];
        }
        else if([className isEqual:@"__NSCFBoolean"]){
            NSLog(@"key type b %@",[[fieldsandtypes objectForKey:key] class]);
            [collection setSearchField:key withType:JSONStore_Boolean];
        }
        else if([[fieldsandtypes objectForKey:key] isKindOfClass: [NSNumber class]]){
            NSLog(@"key type i %@",[[fieldsandtypes objectForKey:key] class]);
            [collection setSearchField:key withType:JSONStore_Integer];
        }

    }
    return collection;

}


RCT_EXPORT_METHOD(createCollection :(NSString *)collectionName fields:(NSDictionary *)fieldsandtypes resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{

    NSError *error = nil;
    NSMutableDictionary* response = [NSMutableDictionary new];
    JSONStoreCollection* collection = [[JSONStoreCollection alloc] initWithName:collectionName];
    collection = [self setCollection:collection forFields: fieldsandtypes];
    [[JSONStore sharedInstance] openCollections:@[collection] withOptions:nil error:&error];
    if(error != nil){
        NSDictionary * d =[self sendErrorDetails:JSONSTORE_CREATE_ERROR error:[error localizedDescription] occuredEvent:collectionName];
        [response setObject:d forKey:@"response"];
        resolve(response);
    }
    else{
        [response setObject:JSONSTORE_SUCCESS forKey:@"response"];
        resolve(response);
    }
}

/*
 RCT_EXPORT_METHOD(createCollection:(NSString *)collectionName fields:(NSDictionary *)fieldsandtypes: (RCTResponseSenderBlock)errorBlock:(RCTResponseSenderBlock)callback)
 {
 NSError *error = nil;
 JSONStoreCollection* collection = [[JSONStoreCollection alloc] initWithName:collectionName];
 collection = [self setCollection:collection forFields: fieldsandtypes];
 [[JSONStore sharedInstance] openCollections:@[collection] withOptions:nil error:&error];
 if(error != nil){
 NSDictionary * d =[self sendErrorDetails:JSONSTORE_CREATE_ERROR error:[error localizedDescription] occuredEvent:collectionName];
 errorBlock(@[d]);
 }
 else{
 callback(@[JSONSTORE_SUCCESS]);
 }
 }
 */

RCT_EXPORT_METHOD(addToCollection :(NSString *)collectionName fields:(NSDictionary *)insertdata resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    NSError *error = nil;
    NSMutableDictionary* response = [NSMutableDictionary new];
    JSONStoreCollection *collection = [[JSONStore sharedInstance] getCollectionWithName:collectionName];
    [[collection addData:@[insertdata] andMarkDirty:YES withOptions:nil error:&error] intValue];
    if(error != nil){
        NSDictionary * d =[self sendErrorDetails:JSONSTORE_ADDITION_ERROR error:[error localizedDescription] occuredEvent:collectionName];
        [response setObject:d forKey:@"response"];
        resolve(response);
    }
    else{
        [response setObject:JSONSTORE_SUCCESS forKey:@"response"];
        resolve(response);
    }
}
/*
 RCT_EXPORT_METHOD(addToCollection:(NSString *)collectionName fields:(NSDictionary *)insertdata: (RCTResponseSenderBlock)errorBlock:(RCTResponseSenderBlock)callback)
 {
 NSError *error = nil;
 JSONStoreCollection *collection = [[JSONStore sharedInstance] getCollectionWithName:collectionName];
 [[collection addData:@[insertdata] andMarkDirty:YES withOptions:nil error:&error] intValue];
 if(error != nil){
 NSDictionary * d =[self sendErrorDetails:JSONSTORE_ADDITION_ERROR error:[error localizedDescription]  occuredEvent:collectionName];
 errorBlock(@[d]);
 }
 else{
 callback(@[JSONSTORE_SUCCESS]);
 }
 }
 */
RCT_EXPORT_METHOD(findFromCollection :(NSString *)collectionName fields:(NSDictionary *)searchfieldandvalues limit: (NSNumber *) limit resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    NSError *error = nil;
    NSMutableDictionary* response = [NSMutableDictionary new];
    JSONStoreCollection *collection = [[JSONStore sharedInstance] getCollectionWithName:collectionName];
    JSONStoreQueryPart* query = [self getSearchFields:searchfieldandvalues];
    JSONStoreQueryOptions *options = [[JSONStoreQueryOptions alloc] init];
    [options setLimit:limit];
    NSArray *results = [collection findWithQueryParts:@[query] andOptions:options error:&error];
    if(error != nil){
        NSDictionary * d =[self sendErrorDetails:JSONSTORE_FIND_ERROR error:[error localizedDescription] occuredEvent:collectionName];
        [response setObject:d forKey:@"response"];
        resolve(response);
    }
    else{
        [response setObject:results forKey:@"response"];
        resolve(response);
    }
}

/*
 RCT_EXPORT_METHOD(findFromCollection:(NSString *)collectionName fields:(NSDictionary *)searchfieldandvalues: limit int:  (RCTResponseSenderBlock)errorBlock:(RCTResponseSenderBlock)callback)
 {
 NSError *error = nil;
 JSONStoreCollection *collection = [[JSONStore sharedInstance] getCollectionWithName:collectionName];
 JSONStoreQueryPart* query = [self getSearchFields:searchfieldandvalues];
 JSONStoreQueryOptions *options = [[JSONStoreQueryOptions alloc] init];
 [options setLimit:limit];
 NSArray *results = [collection findWithQueryParts:@[query] andOptions:options error:&error];
 if(error != nil){
 NSDictionary * d =[self sendErrorDetails:JSONSTORE_FIND_ERROR error:[error localizedDescription]  occuredEvent:collectionName];
 errorBlock(@[d]);
 }
 else{
 callback(@[results]);
 }
 }
 */

RCT_EXPORT_METHOD(replaceFromCollection:(NSString *)collectionName fields:(NSDictionary *)replaceData replaceID: (NSNumber *) replaceID resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    NSError *error = nil;
    NSMutableDictionary* response = [NSMutableDictionary new];
    JSONStoreCollection *collection = [[JSONStore sharedInstance] getCollectionWithName:collectionName];
    NSDictionary *replacement = @{@"_id": replaceID, @"json" : replaceData};
    [collection replaceDocuments:@[replacement] andMarkDirty:YES error:&error];
    if(error != nil){
        NSDictionary * d =[self sendErrorDetails:JSONSTORE_REPLACE_ERROR error:[error localizedDescription] occuredEvent:collectionName];
        [response setObject:d forKey:@"response"];
        resolve(response);
    }
    else{
        [response setObject:JSONSTORE_SUCCESS forKey:@"response"];
        resolve(response);
    }
}

/*
 RCT_EXPORT_METHOD(replaceFromCollection:(NSString *)collectionName fields:(NSDictionary *)replaceData: replaceID int:  (RCTResponseSenderBlock)errorBlock:(RCTResponseSenderBlock)callback)
 {
 NSError *error = nil;
 JSONStoreCollection *collection = [[JSONStore sharedInstance] getCollectionWithName:collectionName];
 NSDictionary *replacement = @{@"_id": replaceID, @"json" : replaceData};
 [collection replaceDocuments:@[replacement] andMarkDirty:YES error:&error];
 if(error != nil){
 NSDictionary * d =[self sendErrorDetails:JSONSTORE_REPLACE_ERROR error:[error localizedDescription]  occuredEvent:collectionName];
 errorBlock(@[d]);
 }
 else{
 callback(@[JSONSTORE_SUCCESS]);
 }
 }
 */

RCT_EXPORT_METHOD(removeFromCollection:(NSString *)collectionName removeID: (NSNumber *) removeID resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    NSError *error = nil;
    NSMutableDictionary* response = [NSMutableDictionary new];
    JSONStoreCollection *collection = [[JSONStore sharedInstance] getCollectionWithName:collectionName];
    [collection removeWithIds:@[removeID] andMarkDirty:YES error:&error];
    if(error != nil){
        NSDictionary * d =[self sendErrorDetails:JSONSTORE_REMOVE_ERROR error:[error localizedDescription] occuredEvent:collectionName];
        [response setObject:d forKey:@"response"];
        resolve(response);
    }
    else{
        [response setObject:JSONSTORE_SUCCESS forKey:@"response"];
        resolve(response);
    }
}
/*
 RCT_EXPORT_METHOD(removeFromCollection:(NSString *)collectionName: removeID int:(RCTResponseSenderBlock)errorBlock:(RCTResponseSenderBlock)callback)
 {
 NSError *error = nil;
 JSONStoreCollection *collection = [[JSONStore sharedInstance] getCollectionWithName:collectionName];
 [collection removeWithIds:@[removeID] andMarkDirty:YES error:&error];
 if(error != nil){
 NSDictionary * d =[self sendErrorDetails:JSONSTORE_REMOVE_ERROR error:[error localizedDescription]  occuredEvent:collectionName];
 errorBlock(@[d]);
 }
 else{
 callback(@[JSONSTORE_SUCCESS]);
 }
 }
 */
RCT_EXPORT_METHOD(removeCollection:(NSString *)collectionName resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    NSError *error = nil;
    NSMutableDictionary* response = [NSMutableDictionary new];
    JSONStoreCollection *collection = [[JSONStore sharedInstance] getCollectionWithName:collectionName];
    BOOL isRemoveWorked = [collection removeCollectionWithError:&error];
    if(error != nil){
        NSDictionary * d =[self sendErrorDetails:JSONSTORE_REMOVE_COLLECTION_ERROR error:[error localizedDescription] occuredEvent:collectionName];
        [response setObject:d forKey:@"response"];
        resolve(response);
    }
    else{
        [response setObject:JSONSTORE_SUCCESS forKey:@"response"];
        resolve(response);
    }
}
/*
 RCT_EXPORT_METHOD(removeCollection:(NSString *)collectionName:  (RCTResponseSenderBlock)errorBlock:(RCTResponseSenderBlock)callback)
 {
 NSError *error = nil;
 JSONStoreCollection *collection = [[JSONStore sharedInstance] getCollectionWithName:collectionName];
 BOOL isRemoveWorked = [collection removeCollectionWithError:&error];
 if(error != nil){
 NSDictionary * d =[self sendErrorDetails:JSONSTORE_REMOVE_COLLECTION_ERROR error:[error localizedDescription]  occuredEvent:collectionName];
 errorBlock(@[d]);
 }
 else{
 callback(@[JSONSTORE_SUCCESS]);
 }
 }
 */
RCT_EXPORT_METHOD(destroyAll:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    NSError *error = nil;
    NSMutableDictionary* response = [NSMutableDictionary new];
    [[JSONStore sharedInstance] destroyDataAndReturnError:&error];
    if(error != nil){
        NSDictionary * d =[self sendErrorDetails:JSONSTORE_DESTROY_ALL_ERROR error:[error localizedDescription] occuredEvent:@""];
        [response setObject:d forKey:@"response"];
        resolve(response);
    }
    else{
        [response setObject:JSONSTORE_SUCCESS forKey:@"response"];
        resolve(response);
    }
}
/*
 RCT_EXPORT_METHOD(destroyAll:(RCTResponseSenderBlock)errorBlock:(RCTResponseSenderBlock)callback)
 {
 NSError *error = nil;
 [[JSONStore sharedInstance] destroyDataAndReturnError:&error];
 if(error != nil){
 NSDictionary * d =[self sendErrorDetails:JSONSTORE_DESTROY_ALL_ERROR error:[error localizedDescription]  occuredEvent:@""];
 errorBlock(@[d]);
 }
 else{
 callback(@[JSONSTORE_SUCCESS]);
 }
 }
 */

 RCT_EXPORT_METHOD(findAllDirtyDocuments:(NSString *)collectionName resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    NSError *error = nil;
    NSMutableDictionary* response = [NSMutableDictionary new];
    JSONStoreCollection *collection = [[JSONStore sharedInstance] getCollectionWithName:collectionName];
    NSArray *results = [collection allDirtyAndReturnError:&error];
    if(error != nil){
        NSDictionary * d =[self sendErrorDetails:JSONSTORE_FIND_DIRTY_ERROR error:[error localizedDescription] occuredEvent:collectionName];
        [response setObject:d forKey:@"response"];
        resolve(response);
    }
    else{
        [response setObject:results forKey:@"response"];
        resolve(response);
    }
}
@end
