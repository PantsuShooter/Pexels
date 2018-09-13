//
//  FavoriteManager.h
//  Pexels
//
//  Created by Цындрин Антон on 13.08.2018.
//  Copyright © 2018 Цындрин Антон. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CuratedPhotoModel;

@interface FavoriteManager : NSObject



+ (FavoriteManager*) favoriteManager;

- (void)addToArraySelectedModel:(CuratedPhotoModel*)selectedModel;

- (NSArray*)getArraryWithSelectedModel;

@end
