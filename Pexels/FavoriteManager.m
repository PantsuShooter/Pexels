//
//  FavoriteManager.m
//  Pexels
//
//  Created by Цындрин Антон on 13.08.2018.
//  Copyright © 2018 Цындрин Антон. All rights reserved.
//

#import "FavoriteManager.h"
#import "CuratedPhotoModel.h"
#import "RKDropdownAlert.h"
#import <MagicalRecord/MagicalRecord.h>

#import "FavoritePhotoSrc+CoreDataClass.h"
#import "FavoritePhotoModel+CoreDataClass.h"

@interface FavoriteManager ()

@end
@implementation FavoriteManager

+ (FavoriteManager*) favoriteManager {
    
    static FavoriteManager *manager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[FavoriteManager alloc] init];
    });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)addToArraySelectedModel:(CuratedPhotoModel*)selectedModel{
    
    FavoritePhotoModel *personFromContext = [FavoritePhotoModel MR_findFirstByAttribute:@"favoritePhotoId" withValue:selectedModel.photoId];
    
    if (personFromContext) {
        NSLog(@"FavoriteManager.m| object already exist in core data");
        
        NSString *alertString = [NSString stringWithFormat:@"You already added a photo to favorites."];
        [self alertWithTitleString:@"Error!" andmassageString:alertString];
    }
    else{
    
    FavoritePhotoModel *favoritePhotoModel = [FavoritePhotoModel MR_createEntity];
    FavoritePhotoSrc *favoritePhotoSrc     = [FavoritePhotoSrc MR_createEntity];
    
        
    [favoritePhotoModel setFavoritePhotoWidth:selectedModel.photoWidth];
    [favoritePhotoModel setFavoritePhotoUrl:selectedModel.photoUrl];
    [favoritePhotoModel setFavoritePhotoPhotographer:selectedModel.photoPhotographer];
    [favoritePhotoModel setFavoritePhotoId:selectedModel.photoId];
    [favoritePhotoModel setFavoritePhotoHeight:selectedModel.photoWidth];
    [favoritePhotoModel setFavoritePhotoAddDate:[NSDate date]];
    
    [favoritePhotoSrc setFavoriteLandscape:[selectedModel.photoSrc valueForKey:@"landscape"]];
    [favoritePhotoSrc setFavoriteLarge:[selectedModel.photoSrc valueForKey:@"large"]];
    [favoritePhotoSrc setFavoriteLarge2x:[selectedModel.photoSrc valueForKey:@"large2x"]];
    [favoritePhotoSrc setFavoriteMedium:[selectedModel.photoSrc valueForKey:@"medium"]];
    [favoritePhotoSrc setFavoriteOriginal:[selectedModel.photoSrc valueForKey:@"original"]];
    [favoritePhotoSrc setFavoritePortrait:[selectedModel.photoSrc valueForKey:@"portrait"]];
    [favoritePhotoSrc setFavoriteSmall:[selectedModel.photoSrc valueForKey:@"small"]];
    [favoritePhotoSrc setFavoriteSquare:[selectedModel.photoSrc valueForKey:@"square"]];
    [favoritePhotoSrc setFavoriteTiny:[selectedModel.photoSrc valueForKey:@"tiny"]];

    favoritePhotoModel.favoritePhotoSrc = favoritePhotoSrc;
    
    
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
        if (success) {
            NSLog(@"FavoriteManager.m| You successfully saved your context.");
            NSString *alertString = [NSString stringWithFormat:@"Photo has been added to favorites."];
            [self alertWithTitleString:@"Success!" andmassageString:alertString];
            
        } else if (error) {
            NSLog(@"Error saving context: %@", error.description);
        }
        
    }];
   }
}



- (NSArray*)getArraryWithSelectedModel{
    
    NSArray *favorite = [FavoritePhotoModel MR_findAllSortedBy:@"favoritePhotoAddDate" ascending:YES];
    
    return favorite;
}

- (void)alertWithTitleString:(NSString*)titleString andmassageString:(NSString*)massageString{

    [RKDropdownAlert title:titleString message:massageString backgroundColor:[UIColor blackColor] textColor:[UIColor orangeColor] time:2.0f delegate:nil];
}

@end
