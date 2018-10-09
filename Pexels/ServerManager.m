//
//  ServerManager.m
//  Pexels
//
//  Created by Цындрин Антон on 07.08.2018.
//  Copyright © 2018 Цындрин Антон. All rights reserved.
//

#import "ServerManager.h"
#import <AFNetworking.h>

#define REQUEST_BASE_URL  @"https://api.pexels.com/v1/"
#define API_KEY           @"563492ad6f91700001000001ab117dff83d54f16a787e8872143d4f0"

@interface ServerManager ()

@property(strong,nonatomic)AFHTTPSessionManager *sessionManager;

@end

@implementation ServerManager

+ (ServerManager*)sharedManager {
    
    static ServerManager *manager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[ServerManager alloc] init];
    });
    
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        NSURL *baseURL = [NSURL URLWithString:REQUEST_BASE_URL];
        self.sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
        self.sessionManager.requestSerializer =  [AFJSONRequestSerializer serializer];
        [self.sessionManager.requestSerializer setValue:API_KEY forHTTPHeaderField:@"Authorization"];
    }
    return self;
}

- (void)getCuratedPhotosPerPage:(NSInteger)perPage
                     page:(NSInteger)page
                onSuccess:(void(^)(NSArray* photos)) success
                onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure {
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
     @(perPage), @"per_page",
     @(page),     @"page",nil];
    
    [self.sessionManager GET:@"curated"
                  parameters:parameters
                    progress:^(NSProgress * _Nonnull downloadProgress) {
                        NSLog(@"downloadProgress %@",downloadProgress);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        //NSLog(@"%@",responseObject);
        NSArray *photos = [responseObject objectForKey:@"photos"];
        if (success) {
            success(photos);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error %@",error);
    }];
}

- (void)getSearchPhotoUseQuery:(NSString *)query
                      perPage:(NSInteger)perPage
                          page:(NSInteger)page
                     onSuccess:(void (^)(NSArray *))success
                     onFailure:(void (^)(NSError *, NSInteger))failure{
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                query,       @"query",
                                @(perPage), @"per_page",
                                @(page),     @"page",nil];
    
    
    [self.sessionManager GET:@"search"
                  parameters:parameters
                    progress:^(NSProgress * _Nonnull downloadProgress) {
                        NSLog(@"downloadProgress %@",downloadProgress);
                    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                        NSArray *photos = [responseObject objectForKey:@"photos"];
                        if (success) {
                            success(photos);
                        }
                    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                        NSLog(@"error %@",error);
                    }];
}

@end
