//
//  CustomViewActionController.m
//  Pexels
//
//  Created by Цындрин Антон on 11.08.2018.
//  Copyright © 2018 Цындрин Антон. All rights reserved.
//

#import "CustomViewActionController.h"

@interface CustomViewActionController ()

@end

@implementation CustomViewActionController

- (nullable instancetype)initWithStyle:(RMActionControllerStyle)aStyle title:(NSString *)aTitle message:(NSString *)aMessage selectAction:(RMAction *)selectAction andCancelAction:(RMAction *)cancelAction {
    
    self = [super initWithStyle:aStyle title:aTitle message:aMessage selectAction:selectAction andCancelAction:cancelAction ];
    if(self) {
        self.contentView = [[UIView alloc] initWithFrame:CGRectZero];
        self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return self;
}

@end
