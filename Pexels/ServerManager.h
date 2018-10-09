//
//  ServerManager.h
//  Pexels
//
//  Created by Цындрин Антон on 07.08.2018.
//  Copyright © 2018 Цындрин Антон. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ServerManager : NSObject

+ (ServerManager*)sharedManager;

- (void)getCuratedPhotosPerPage:(NSInteger)perPage
                     page:(NSInteger)page
                onSuccess:(void(^)(NSArray* photos)) success
                onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure;


- (void)getSearchPhotoUseQuery:(NSString *)query
                     perPage:(NSInteger)perPage
                         page:(NSInteger)page
                    onSuccess:(void(^)(NSArray *photos)) success
                    onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure;

@end
