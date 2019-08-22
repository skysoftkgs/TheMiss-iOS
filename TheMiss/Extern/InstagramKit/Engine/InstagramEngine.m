//
//    Copyright (c) 2013 Shyam Bhat
//
//    Permission is hereby granted, free of charge, to any person obtaining a copy of
//    this software and associated documentation files (the "Software"), to deal in
//    the Software without restriction, including without limitation the rights to
//    use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
//    the Software, and to permit persons to whom the Software is furnished to do so,
//    subject to the following conditions:
//
//    The above copyright notice and this permission notice shall be included in all
//    copies or substantial portions of the Software.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
//    FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
//    COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
//    IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//    CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "InstagramEngine.h"
#import "InstagramUser.h"
#import "InstagramMedia.h"
#import "InstagramComment.h"
#import "InstagramTag.h"

#define kKeyClientID @"client_id"
#define kKeyAccessToken @"access_token"

NSString *const kInstagramKitAppClientIdConfigurationKey = @"InstagramKitAppClientId";
NSString *const kInstagramKitAppRedirectUrlConfigurationKey = @"InstagramKitAppRedirectURL";

NSString *const kInstagramKitBaseUrlConfigurationKey = @"InstagramKitBaseUrl";
NSString *const kInstagramKitAuthorizationUrlConfigurationKey = @"InstagramKitAuthorizationUrl";

NSString *const kInstagramKitBaseUrlDefault = @"https://api.instagram.com/v1/";
NSString *const kInstagramKitBaseUrl __deprecated = @"https://api.instagram.com/v1/";

NSString *const kInstagramKitAuthorizationUrlDefault = @"https://api.instagram.com/oauth/authorize/";
NSString *const kInstagramKitAuthorizationUrl __deprecated = @"https://api.instagram.com/oauth/authorize/";
NSString *const kInstagramKitErrorDomain = @"InstagramKitErrorDomain";

#define kData @"data"

@interface InstagramEngine()
{
    dispatch_queue_t mBackgroundQueue;
}

+ (NSDictionary*) sharedEngineConfiguration;

@property (nonatomic, copy) InstagramLoginBlock instagramLoginBlock;
@property (nonatomic, strong) AFHTTPRequestOperationManager *operationManager;

@end

@implementation InstagramEngine

#pragma mark - Initializers -

+ (InstagramEngine *)sharedEngine {
    static InstagramEngine *_sharedEngine = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        _sharedEngine = [[InstagramEngine alloc] init];
    });
    return _sharedEngine;
}

+ (NSDictionary*) sharedEngineConfiguration {
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"InstagramKit" withExtension:@"plist"];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfURL:url];
    dict = dict ? dict : [[NSBundle mainBundle] infoDictionary];
    return dict;
}

- (id)init {
    if (self = [super init])
    {
        NSDictionary *sharedEngineConfiguration = [InstagramEngine sharedEngineConfiguration];
        id url = nil;
        url = sharedEngineConfiguration[kInstagramKitBaseUrlConfigurationKey];
        
        if (url) {
            url = [NSURL URLWithString:url];
        } else {
            url = [NSURL URLWithString:kInstagramKitBaseUrlDefault];
        }
        
        NSAssert(url, @"Base URL not valid: %@", sharedEngineConfiguration[kInstagramKitBaseUrlConfigurationKey]);
        self.operationManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:url];

        self.appClientID =  sharedEngineConfiguration[kInstagramKitAppClientIdConfigurationKey];
        self.appRedirectURL = sharedEngineConfiguration[kInstagramKitAppRedirectUrlConfigurationKey];

        url = sharedEngineConfiguration[kInstagramKitAuthorizationUrlConfigurationKey];
        self.authorizationURL = url ? url : kInstagramKitAuthorizationUrlDefault;

        mBackgroundQueue = dispatch_queue_create("background", NULL);

        self.operationManager.responseSerializer = [[AFJSONResponseSerializer alloc] init];

        BOOL validClientId = IKNotNull(self.appClientID) && ![self.appClientID isEqualToString:@""] && ![self.appClientID isEqualToString:@"<Client Id here>"];
        NSAssert(validClientId, @"Invalid Instagram Client ID.");
        NSAssert([NSURL URLWithString:self.appRedirectURL], @"App Redirect URL invalid: %@", self.appRedirectURL);
        NSAssert([NSURL URLWithString:self.authorizationURL], @"Authorization URL invalid: %@", self.authorizationURL);
    }
    return self;
}

#pragma mark - Login -

- (void)cancelLogin
{
    if (self.instagramLoginBlock)
    {
        NSString *localizedDescription = NSLocalizedString(@"User canceled Instagram Login.", @"Error notification for Instagram Login cancelation.");
        NSError *error = [NSError errorWithDomain:kInstagramKitErrorDomain code:kInstagramKitErrorCodeUserCancelled userInfo:@{
            NSLocalizedDescriptionKey: localizedDescription
        }];
        self.instagramLoginBlock(error);
    }
}

- (void)loginWithBlock:(InstagramLoginBlock)block
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?client_id=%@&redirect_uri=%@&response_type=token",
        self.authorizationURL,
        self.appClientID,
        self.appRedirectURL]];

    self.instagramLoginBlock = block;

    [[UIApplication sharedApplication] openURL:url];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{

    NSURL *appRedirectURL = [NSURL URLWithString:self.appRedirectURL];

    if (![appRedirectURL.scheme isEqual:url.scheme] || ![appRedirectURL.host isEqual:url.host])
    {
        return NO;
    }
    
    NSString* accessToken = [self queryStringParametersFromString:url.fragment][@"access_token"];
    if (accessToken)
    {
        self.accessToken = accessToken;
        if (self.instagramLoginBlock) self.instagramLoginBlock(nil);
    }
    else if (self.instagramLoginBlock)
    {
        NSString *localizedDescription = NSLocalizedString(@"Authorization not granted.", @"Error notification to indicate Instagram OAuth token was not provided.");
        NSError *error = [NSError errorWithDomain:kInstagramKitErrorDomain code:kInstagramKitErrorCodeAccessNotGranted userInfo:@{
            NSLocalizedDescriptionKey: localizedDescription
        }];
        self.instagramLoginBlock(error);
    }
    self.instagramLoginBlock = nil;
    return YES;
}

-(NSDictionary*)queryStringParametersFromString:(NSString*)string {

    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    for (NSString * param in [string componentsSeparatedByString:@"&"])
    {
        NSArray *pairs = [param componentsSeparatedByString:@"="];
        if ([pairs count] != 2) continue;
        NSString *key = [pairs[0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *value = [pairs[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [dict setObject:value forKey:key];
    }
    return dict;
}

#pragma mark - Base Call -

- (void)getPath:(NSString *)path
     parameters:(NSDictionary *)parameters
  responseModel:(Class)modelClass
        success:(void (^)(id response))success
        failure:(void (^)(NSError* error, NSInteger statusCode))failure
{

    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:parameters];

    if (self.accessToken) {
        [params setObject:self.accessToken forKey:kKeyAccessToken];
    }
    [params setObject:self.appClientID forKey:kKeyClientID];

    [self.operationManager GET:path
        parameters:params
           success:^(AFHTTPRequestOperation *operation, id responseObject) {
               NSDictionary *responseDictionary = (NSDictionary *)responseObject;
               BOOL multiple = ([responseDictionary[kData] isKindOfClass:[NSArray class]]);
               if (multiple) {
                   NSArray *responseObjects = responseDictionary[kData];
                   NSMutableArray*objects = [NSMutableArray arrayWithCapacity:responseObjects.count];
                   dispatch_async(mBackgroundQueue, ^{
                       if (modelClass) {
                           for (NSDictionary *info in responseObjects) {
                               id model = [[modelClass alloc] initWithInfo:info];
                               [objects addObject:model];
                           }
                       }
                       dispatch_async(dispatch_get_main_queue(), ^{
                           success(objects);
                       });
                   });
               }
               else {
                   id model = nil;
                   if (modelClass && IKNotNull(responseDictionary[kData]))
                   {
                       model = [[modelClass alloc] initWithInfo:responseDictionary[kData]];
                   }
                   success(model);
               }
           }
           failure:^(AFHTTPRequestOperation *operation, NSError *error) {
               failure(error,[[operation response] statusCode]);
           }];
}

- (void)postPath:(NSString *)path
     parameters:(NSDictionary *)parameters
   responseModel:(Class)modelClass
        success:(void (^)(void))success
        failure:(void (^)(NSError* error, NSInteger statusCode))failure
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:parameters];
    if (self.accessToken) {
        [params setObject:self.accessToken forKey:kKeyAccessToken];
    }
    else
        [params setObject:self.appClientID forKey:kKeyClientID];
    
    [self.operationManager POST:path
                    parameters:params
                       success:^(AFHTTPRequestOperation *operation, id responseObject) {
                           success();
                       }
                       failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                           failure(error,[[operation response] statusCode]);
                       }];
}


- (void)deletePath:(NSString *)path
      parameters:(NSDictionary *)parameters
   responseModel:(Class)modelClass
         success:(void (^)(void))success
         failure:(void (^)(NSError* error, NSInteger statusCode))failure
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:parameters];
    if (self.accessToken) {
        [params setObject:self.accessToken forKey:kKeyAccessToken];
    }
    else
        [params setObject:self.appClientID forKey:kKeyClientID];
    [self.operationManager DELETE:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success();
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(error,[[operation response] statusCode]);
    }];
}



#pragma mark - Media -

- (void)getPopularMediaWithSuccess:(void (^)(NSArray *media))success
                           failure:(void (^)(NSError* error))failure
{
    [self getPath:@"media/popular" parameters:nil responseModel:[InstagramMedia class] success:^(id response) {
        NSArray *objects = response;
        success(objects);
    } failure:^(NSError *error, NSInteger statusCode) {
        failure(error);
    }];
}

- (void)getMedia:(NSString *)mediaId
               withSuccess:(void (^)(InstagramMedia *media))success
                   failure:(void (^)(NSError* error))failure
{
    [self getPath:[NSString stringWithFormat:@"media/%@",mediaId] parameters:nil responseModel:[InstagramMedia class] success:^(id response) {
        InstagramMedia *media = response;
        success(media);
    } failure:^(NSError *error, NSInteger statusCode) {
        failure(error);
    }];
}

- (void)getMediaAtLocation:(CLLocationCoordinate2D)location
               withSuccess:(void (^)(NSArray *media))success
                   failure:(void (^)(NSError* error))failure
{
    [self getPath:[NSString stringWithFormat:@"media/search?lat=%f&lng=%f",location.latitude,location.longitude] parameters:nil responseModel:[InstagramMedia class] success:^(id response) {
        NSArray *objects = response;
        success(objects);
    } failure:^(NSError *error, NSInteger statusCode) {
        failure(error);
    }];
}

#pragma mark - Users -

- (void)getSelfUserDetailWithSuccess:(void (^)(InstagramUser *userDetail))success
                             failure:(void (^)(NSError* error))failure
{
    [self getPath:@"users/self" parameters:nil responseModel:[InstagramUser class] success:^(id response) {
        InstagramUser *userDetail = response;
        success(userDetail);
    } failure:^(NSError *error, NSInteger statusCode) {
        failure(error);
    }];
}

- (void)getUserDetails:(InstagramUser *)user
     withSuccess:(void (^)(InstagramUser *userDetail))success
         failure:(void (^)(NSError* error))failure
{
    [self getPath:[NSString stringWithFormat:@"users/%@",user.Id]  parameters:nil responseModel:[InstagramUser class] success:^(id response) {
        InstagramUser *userDetail = response;
        success(userDetail);
    } failure:^(NSError *error, NSInteger statusCode) {
        failure(error);
    }];
}

- (void)getMediaForUser:(NSString *)userId count:(NSInteger)count
        withSuccess:(void (^)(NSArray *feed))success
            failure:(void (^)(NSError* error))failure
{
    [self getPath:[NSString stringWithFormat:@"users/%@/media/recent",userId] parameters:@{kCount:[NSString stringWithFormat:@"%d",count]} responseModel:[InstagramMedia class] success:^(id response) {
        NSArray *objects = response;
        success(objects);
    } failure:^(NSError *error, NSInteger statusCode) {
        failure(error);
    }];
}

- (void)searchUsersWithString:(NSString *)string
               withSuccess:(void (^)(NSArray *users))success
                   failure:(void (^)(NSError* error))failure
{
    [self getPath:[NSString stringWithFormat:@"users/search?q=%@",string] parameters:nil responseModel:[InstagramUser class] success:^(id response) {
        NSArray *objects = response;
        success(objects);
    } failure:^(NSError *error, NSInteger statusCode) {
        failure(error);
    }];
}

#pragma mark - Self -

- (void)getSelfFeed:(NSInteger)count
        withSuccess:(void (^)(NSArray *feed))success
            failure:(void (^)(NSError* error))failure
{
    [self getPath:[NSString stringWithFormat:@"users/self/feed"] parameters:nil responseModel:[InstagramMedia class] success:^(id response) {
        NSArray *objects = response;
        success(objects);
        
    } failure:^(NSError *error, NSInteger statusCode) {
        failure(error);
    }];
}

- (void)getSelfLikesWithSuccess:(void (^)(NSArray *feed))success
                        failure:(void (^)(NSError* error))failure
{
    [self getPath:[NSString stringWithFormat:@"users/self/media/liked"] parameters:nil responseModel:[InstagramMedia class] success:^(id response) {
        NSArray *objects = response;
        success(objects);
        
    } failure:^(NSError *error, NSInteger statusCode) {
        failure(error);
    }];
}

#pragma mark - Tags -

- (void)getMediaWithTagName:(NSString *)tag
            withSuccess:(void (^)(NSArray *feed))success
                failure:(void (^)(NSError* error))failure
{
    [self getPath:[NSString stringWithFormat:@"tags/%@/media/recent",tag] parameters:nil responseModel:[InstagramMedia class] success:^(id response) {
        NSArray *objects = response;
        success(objects);
        
    } failure:^(NSError *error, NSInteger statusCode) {
        failure(error);
    }];
}

- (void)getTagWithName:(NSString *)name
     withSuccess:(void (^)(InstagramTag *tag))success
         failure:(void (^)(NSError* error))failure
{
    [self getPath:[NSString stringWithFormat:@"tags/%@",name] parameters:nil responseModel:[InstagramTag class] success:^(id response) {
        InstagramTag *tag = response;
        success(tag);
    } failure:^(NSError *error, NSInteger statusCode) {
        failure(error);
    }];
}

- (void)searchTagsWithName:(NSString *)name
            withSuccess:(void (^)(NSArray *tags))success
                failure:(void (^)(NSError* error))failure
{
    [self getPath:[NSString stringWithFormat:@"tags/search?q=%@",name] parameters:nil responseModel:[InstagramTag class] success:^(id response) {
        NSArray *objects = response;
        success(objects);
    } failure:^(NSError *error, NSInteger statusCode) {
        failure(error);
    }];
}

#pragma mark - Comments -

- (void)getCommentsOnMedia:(InstagramMedia *)media
               withSuccess:(void (^)(NSArray *comments))success
                   failure:(void (^)(NSError* error))failure
{
    [self getPath:[NSString stringWithFormat:@"media/%@/comments",media.Id] parameters:nil responseModel:[InstagramComment class] success:^(id response) {
        NSArray *objects = response;
        success(objects);
    } failure:^(NSError *error, NSInteger statusCode) {
        failure(error);
    }];
}

- (void)createComment:(NSString *)commentText
              onMedia:(InstagramMedia *)media
          withSuccess:(void (^)(void))success
              failure:(void (^)(NSError* error))failure
{
    // Please email apidevelopers@instagram.com for access.
    NSDictionary *params = [NSDictionary dictionaryWithObjects:@[commentText] forKeys:@[kText]];
    [self postPath:[NSString stringWithFormat:@"media/%@/comments",media.Id] parameters:params responseModel:nil success:^{
        success();
    } failure:^(NSError *error, NSInteger statusCode) {
        failure(error);
    }];
}

- (void)removeComment:(NSString *)commentId
              onMedia:(InstagramMedia *)media
          withSuccess:(void (^)(void))success
              failure:(void (^)(NSError* error))failure
{
    [self deletePath:[NSString stringWithFormat:@"media/%@/comments/%@",media.Id,commentId] parameters:nil responseModel:nil success:^{
        success();
    } failure:^(NSError *error, NSInteger statusCode) {
        failure(error);
    }];
}

#pragma mark - Likes -

- (void)getLikesOnMedia:(InstagramMedia *)media
               withSuccess:(void (^)(NSArray *likedUsers))success
                   failure:(void (^)(NSError* error))failure
{
    [self getPath:[NSString stringWithFormat:@"media/%@/likes",media.Id] parameters:nil responseModel:[InstagramUser class] success:^(id response) {
        NSArray *objects = response;
        success(objects);
    } failure:^(NSError *error, NSInteger statusCode) {
        failure(error);
    }];
}

- (void)likeMedia:(InstagramMedia *)media
              withSuccess:(void (^)(void))success
          failure:(void (^)(NSError* error))failure
{
    [self postPath:[NSString stringWithFormat:@"media/%@/likes",media.Id] parameters:nil responseModel:nil success:^{
        success();
    } failure:^(NSError *error, NSInteger statusCode) {
        failure(error);
    }];
}

- (void)unlikeMedia:(InstagramMedia *)media
        withSuccess:(void (^)(void))success
          failure:(void (^)(NSError* error))failure
{
    [self deletePath:[NSString stringWithFormat:@"media/%@/likes",media.Id] parameters:nil responseModel:nil success:^{
        success();
    } failure:^(NSError *error, NSInteger statusCode) {
        failure(error);
    }];
}

@end
