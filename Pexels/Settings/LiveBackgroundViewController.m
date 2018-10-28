//
//  LiveBackgroundViewController.m
//  BackgroundView
//
//  Created by Цындрин Антон on 07.09.2018.
//  Copyright © 2018 Цындрин Антон. All rights reserved.
//

#import "LiveBackgroundViewController.h"

@interface LiveBackgroundViewController ()
@property (weak, nonatomic) IBOutlet UILabel *settingsLable;


- (IBAction)bubbleSegmentedControlAction:(id)sender;
@property (weak, nonatomic) IBOutlet UISegmentedControl *bubbleSegmentedControl;


@property(strong,nonatomic)CAShapeLayer *circleLayer;
@property(strong,nonatomic)UIView *bubbleView;

@property(assign,nonatomic)CGFloat randonWithPosition;
@property(assign,nonatomic)CGFloat randomHeightPosition;

@property(assign,nonatomic)CGPoint touchPoint;

@property(assign,nonatomic)CGFloat bubbleValue;

@end

@implementation LiveBackgroundViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setups];
    [self bubbleViewSetup];
    [self lableSetup];
    
}

- (void)setups {
    
    self.bubbleValue = bubbleMoveRandomly;
    self.bubbleView.backgroundColor = [UIColor blackColor];
    self.bubbleTimeInterval = 0.1f;
    self.circleMinSize = 1.f;
    self.circleMaxSize =30.f;
    self.circleAnimationDuration = 3.f;
    self.circleFillColor = [UIColor clearColor];
    self.circleStrokeColor = [UIColor redColor];
    self.touchPoint = self.view.center;
}

- (void)bubbleViewSetup{
    
    [NSTimer scheduledTimerWithTimeInterval:self.bubbleTimeInterval target:self selector:@selector(makeCircle) userInfo:nil repeats:YES];
    
    
    self.bubbleView = [[UIView alloc] initWithFrame:self.view.frame];
    self.bubbleView.backgroundColor = self.bubbleViewBackgroundColor;
    [self.view addSubview:self.bubbleView];
    [self.view sendSubviewToBack:self.bubbleView];
    self.bubbleView.userInteractionEnabled = NO;
    
}

- (void)makeCircle {
    
    self.circleLayer = [CAShapeLayer layer];
    [self.circleLayer setPath:[[UIBezierPath bezierPathWithOvalInRect:[self returnRectWithRandomPositionAndSelectedWidth:self.circleMinSize andHeight:self.circleMinSize]] CGPath]];
    
    [self.circleLayer setStrokeColor:[self.circleStrokeColor CGColor]];
    [self.circleLayer setFillColor:[self.circleFillColor CGColor]];
    
    
    [[self.bubbleView layer] addSublayer:self.circleLayer];
    [self animateCircleWithDuration:self.circleAnimationDuration];
}

- (void)animateCircleWithDuration:(CGFloat)duration{
    
    
    UIBezierPath *newPath = [[UIBezierPath alloc] init];
    
    if (self.bubbleValue == bubbleMoveRandomly) {

    newPath = [UIBezierPath bezierPathWithOvalInRect:[self returnRectWithRandomPositionAndSelectedWidth:self.circleMaxSize andHeight:self.circleMaxSize]];
    }
    else if (self.bubbleValue == bubbleMoveAtOnePlace){

      newPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(self.randonWithPosition - self.circleMaxSize/2,self.randomHeightPosition - self.circleMaxSize/2, self.circleMaxSize, self.circleMaxSize)];
    }
    else{
    
    newPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(self.touchPoint.x - self.circleMaxSize/2,self.touchPoint.y - self.circleMaxSize/2, self.circleMaxSize, self.circleMaxSize)];
    }
    
    
    CABasicAnimation* pathAnim = [CABasicAnimation animationWithKeyPath: @"path"];
    pathAnim.toValue = (id)newPath.CGPath;
    
    CAAnimationGroup *anims = [CAAnimationGroup animation];
    anims.animations = [NSArray arrayWithObject:pathAnim];
    anims.removedOnCompletion = NO;
    anims.duration = duration;
    anims.fillMode  = kCAFillModeForwards;
    
    [self.circleLayer addAnimation:anims forKey:nil];
    
    [NSTimer scheduledTimerWithTimeInterval:duration -0.5f
                                    repeats:NO
                                      block:^(NSTimer * _Nonnull timer) {
                                          
                                
                                          [[self.bubbleView.layer.sublayers objectAtIndex:0] removeFromSuperlayer];
                                          
    }];
}



- (CGRect)returnRectWithRandomPositionAndSelectedWidth:(CGFloat)width andHeight:(CGFloat)height {
    CGFloat randonWithPosition = arc4random_uniform(self.view.frame.size.width);
    CGFloat randomHeightPosition = arc4random_uniform(self.view.frame.size.height);
    CGRect rect = CGRectMake(randonWithPosition, randomHeightPosition, width, height);
    
    self.randonWithPosition = randonWithPosition;
    self.randomHeightPosition = randomHeightPosition;
    
    return rect;
}



- (void) touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
    
    UITouch *touch=[[event allTouches]anyObject];
    self.touchPoint = [touch locationInView:self.view];
}

- (void) touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event
{
    
    UITouch *touch=[[event allTouches]anyObject];
    self.touchPoint = [touch locationInView:self.view];
}


- (IBAction)bubbleSegmentedControlAction:(id)sender {
    
    if (self.bubbleSegmentedControl.selectedSegmentIndex == 0) {
        self.bubbleValue = bubbleMoveRandomly;
    }
    else if (self.bubbleSegmentedControl.selectedSegmentIndex == 1){
        self.bubbleValue = bubbleMoveAtOnePlace;
    }
    else {
        self.bubbleValue = bubbleMoveAtTouchPoint;
    }
    
}

- (void)lableSetup {
    
    self.settingsLable.text = @"This application uses Pexels API.\nhttps://www.pexels.com/api/\n\nPods was used:\n\n'AFNetworking', '~> 3.0'\n'SDWebImage', '~> 4.0'\n'SVPullToRefresh'\n'RMActionController', '~> 1.3.1'\n'RKDropdownAlert'\n'MagicalRecord/CocoaLumberjack'\n'MMParallaxCell'\n'NYTPhotoViewer', '~> 1.0.0'\n'MONActivityIndicatorView'\n'JBWebViewController'";
    
}

@end
