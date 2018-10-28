//
//  LiveBackgroundViewController.h
//  BackgroundView
//
//  Created by Цындрин Антон on 07.09.2018.
//  Copyright © 2018 Цындрин Антон. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LiveBackgroundViewController : UIViewController

typedef enum {
    bubbleMoveRandomly,
    bubbleMoveAtOnePlace,
    bubbleMoveAtTouchPoint
} bubbleMove;


@property(strong,nonatomic)UIColor *bubbleViewBackgroundColor;

@property(strong,nonatomic)UIColor *circleStrokeColor;
@property(strong,nonatomic)UIColor *circleFillColor;

@property(assign,nonatomic)CGFloat circleAnimationDuration;

@property(assign,nonatomic)CGFloat circleMinSize;
@property(assign,nonatomic)CGFloat circleMaxSize;

@property(assign,nonatomic)CGFloat bubbleTimeInterval;


@end
