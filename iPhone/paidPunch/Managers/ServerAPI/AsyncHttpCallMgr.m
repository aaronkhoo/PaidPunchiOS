//
//  AsyncHttpCallMgr.m
//  traderpog
//
//  Created by Aaron Khoo on 8/28/12.
//  Copyright (c) 2012 GeoloPigs. All rights reserved.
//

#import "AFClientManager.h"
#import "AFHTTPRequestOperation.h"
#import "AsyncHttpCallMgr.h"

static int const maxRetry = 3;
static NSString* const kAsyncHttpCallMgrFilename = @"asynchttpcallmgr.sav";

// encoding keys
static NSString* const kKeyVersion = @"version";
static NSString* const kKeyCallArray = @"callarray";

@interface AsyncHttpCallMgr ()
{
    // internal
    NSString* _createdVersion;
    
    // Delegates for callbacks to inform interested parties of completion
    NSMutableArray* _arrayDelegates;
    
    NSMutableArray* _callArray;
    NSCondition* _lock;
    BOOL _callsInProgress;
}
@end

@implementation AsyncHttpCallMgr

- (id) init
{
    self = [super init];
    if(self)
    {
        _callArray = [[NSMutableArray alloc] init];
        _lock = [[NSCondition alloc] init];
        _callsInProgress = FALSE;
        _arrayDelegates = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void) addDelegateInstance:(__weak NSObject<AsyncHttpDelegate>*) delegate
{
    [_arrayDelegates addObject:delegate];
}

#pragma mark - NSCoding
- (void) encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_createdVersion forKey:kKeyVersion];
    [aCoder encodeObject:_callArray forKey:kKeyCallArray];
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    _createdVersion = [aDecoder decodeObjectForKey:kKeyVersion];
    _callArray = [aDecoder decodeObjectForKey:kKeyCallArray];
    _lock = [[NSCondition alloc] init];
    _callsInProgress = FALSE;
    _arrayDelegates = [[NSMutableArray alloc] init];
    return self;
}

#pragma mark - saved game data loading and unloading
+ (AsyncHttpCallMgr*) loadAsyncHttpCallMgrData
{
    AsyncHttpCallMgr* current = nil;
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSString* filepath = [AsyncHttpCallMgr asyncHttpCallMgrFilePath];
    if ([fileManager fileExistsAtPath:filepath])
    {
        NSData* readData = [NSData dataWithContentsOfFile:filepath];
        if(readData)
        {
            current = [NSKeyedUnarchiver unarchiveObjectWithData:readData];
        }
    }
    return current;
}

- (void) saveAsyncHttpCallMgrData
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self];
    NSError* error = nil;
    BOOL writeSuccess = [data writeToFile:[AsyncHttpCallMgr asyncHttpCallMgrFilePath]
                                  options:NSDataWritingAtomic
                                    error:&error];
    if(writeSuccess)
    {
        NSLog(@"AsyncHttpCallMgr file saved successfully");
    }
    else
    {
        NSLog(@"AsyncHttpCallMgr file save failed: %@", error);
    }
}

- (void) removeAsyncHttpCallMgrData
{
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSString* filepath = [AsyncHttpCallMgr asyncHttpCallMgrFilePath];
    NSError *error = nil;
    if ([fileManager fileExistsAtPath:filepath])
    {
        [fileManager removeItemAtPath:filepath error:&error];
    }
}

#pragma mark - private functions
- (void) callDelegates:(BOOL)success
{
    for (id obj in _arrayDelegates)
    {
        NSObject<AsyncHttpDelegate>* delegate = (NSObject<AsyncHttpDelegate>*)obj;
        [delegate didCompleteAsyncHttpCallback:success];
    }
}

+ (NSString*) documentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return documentsDirectory;
}

+ (NSString*) asyncHttpCallMgrFilePath
{
    NSString* docsDir = [self documentsDirectory];
    NSString* filepath = [docsDir stringByAppendingPathComponent:kAsyncHttpCallMgrFilename];
    return filepath;
}

- (void) push:(AsyncHttpCall*) newCall
{
    @synchronized(self)
    {
        [_callArray addObject:newCall];   
    }
}

- (void) pop
{
    @synchronized(self)
    {
        [_callArray removeObjectAtIndex:0];
    }
}

- (void) makeAsyncHttpCall
{    
    AsyncHttpCall* nextCall = (AsyncHttpCall*)[_callArray objectAtIndex:0];
    
    if (nextCall.type == putType || nextCall.type == postType)
    {
        AFHTTPClient* httpClient = [[AFClientManager sharedInstance] paidpunch];
        
        // Set the headers
        NSDictionary* headers = [nextCall headers];
        if (headers)
        {
            for (id key in headers)
            {
                [httpClient setDefaultHeader:(NSString*)key value:(NSString*)[headers objectForKey:key]];
            }
        }
        
        // Make the call
        if (nextCall.type == putType)
        {
            // make a post request            
            [httpClient putPath:[nextCall path]
                     parameters:[nextCall parameters]
                        success:^(AFHTTPRequestOperation *operation, id responseObject){
                            NSLog(@"postPath call succeeded in AsyncHttpCallMgr");
                            [self pop];
                            [self callDelegates:TRUE];
                        }
                        failure:^(AFHTTPRequestOperation* operation, NSError* error){
                            NSLog(@"postPath call failed in AsyncHttpCallMgr");
                            NSLog(@"Custom error: %@", [nextCall failureMsg]);
                            // If the failure is a server failure, then auto-retry. Otherwise
                            // cap the number of retries at 3. 
                            if ([[operation response] statusCode] >=400 && [[operation response] statusCode] < 500)
                            {
                                nextCall.numTries++;
                                if ([nextCall numTries] >= maxRetry)
                                {
                                    [self pop];
                                }
                            }
                            [self callDelegates:FALSE];
                        }
             ];
        }
        else if (nextCall.type == postType)
        {
            // make a post request
            [httpClient postPath:[nextCall path]
                     parameters:[nextCall parameters]
                        success:^(AFHTTPRequestOperation *operation, id responseObject){
                            NSLog(@"postPath call succeeded in AsyncHttpCallMgr");
                            [self pop];
                            [self callDelegates:TRUE];
                        }
                        failure:^(AFHTTPRequestOperation* operation, NSError* error){
                            NSLog(@"postPath call failed in AsyncHttpCallMgr");
                            NSLog(@"Custom error: %@", [nextCall failureMsg]);
                            // If the failure is a server failure, then auto-retry. Otherwise
                            // cap the number of retries at 3.
                            if ([[operation response] statusCode] >=400 && [[operation response] statusCode] < 500)
                            {
                                nextCall.numTries++;
                                if ([nextCall numTries] >= maxRetry)
                                {
                                    [self pop];
                                }
                            }
                            [self callDelegates:FALSE];
                        }
             ];
        }
        
        // Reset the headers
        if (headers)
        {
            for (id key in headers)
            {
                [httpClient setDefaultHeader:(NSString*)key value:nil];
            }
        }
    }
    else
    {
        NSLog(@"Unknown http call type in makeAsyncHttpCall for AsyncHttpCallMgr class");
        [self pop];
        [self callDelegates:FALSE];
    }
}

#pragma mark - public functions
- (void) newAsyncHttpCall:(NSString*)path
           current_params:(NSDictionary*)params
          current_headers:(NSDictionary*)headers
              current_msg:(NSString*)msg
             current_type:(httpCallType)type
{
    AsyncHttpCall* newCall = [[AsyncHttpCall alloc] initWithValues:path
                                                    current_params:params
                                                   current_headers:headers
                                                       current_msg:msg
                                                      current_type:type];
    [self push:newCall];
    
    [self startCalls];
}

- (BOOL) startCalls
{
    BOOL startCall = FALSE;
    
    [_lock lock];
    if (!_callsInProgress && [_callArray count] > 0)
    {
        _callsInProgress = TRUE;
        startCall = TRUE;
    }
    [_lock unlock];
    
    if (startCall)
    {
        [self makeAsyncHttpCall];
    }
    
    return startCall;
}

- (BOOL) callsRemain
{
    return ([_callArray count] > 0);
}

- (void)applicationDidEnterBackground
{
    // Save any calls that haven't been made
    [self saveAsyncHttpCallMgrData];
}

- (void)applicationWillTerminate
{
    // Save any calls that haven't been made
    [self saveAsyncHttpCallMgrData];
}

#pragma mark - AsyncHttpDelegate
- (void) didCompleteAsyncHttpCallback:(BOOL)success
{
    if (success && [_callArray count] > 0)
    {
        [self makeAsyncHttpCall];
    }
    else
    {
        [_lock lock];
        _callsInProgress = FALSE;
        [_lock unlock];
    }
}

#pragma mark - Singleton
static AsyncHttpCallMgr* singleton = nil;
+ (AsyncHttpCallMgr*) getInstance
{
	@synchronized(self)
	{
		if (!singleton)
		{
            // First, try to load the AsyncHttpCallMgr data from disk
            singleton = [AsyncHttpCallMgr loadAsyncHttpCallMgrData];
            if (!singleton)
            {
                // OK, no saved data available. Go ahead and create a new AsyncHttpCallMgr instance.
                singleton = [[AsyncHttpCallMgr alloc] init];
            }
		}
	}
	return singleton;
}

+ (void) destroyInstance
{
	@synchronized(self)
	{
		singleton = nil;
	}
}

@end
