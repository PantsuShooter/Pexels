//
//  CuratedPhotoModel.h
//  Pexels
//
//  Created by Цындрин Антон on 08.08.2018.
//  Copyright © 2018 Цындрин Антон. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CuratedPhotoModel : NSObject

@property(strong,nonatomic)NSString *photoPhotographer;
@property(assign,nonatomic)double photoHeight;
@property(assign,nonatomic)double photoWidth;
@property(strong,nonatomic)NSString *photoId;
@property(strong,nonatomic)NSString *photoUrl;

@property(strong,nonatomic)NSArray *photoSrc;


@end
