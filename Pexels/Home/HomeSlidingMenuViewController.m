//
//  HomeSlidingMenuViewController.m
//  Pexels
//
//  Created by Цындрин Антон on 08.08.2018.
//  Copyright © 2018 Цындрин Антон. All rights reserved.
//

#import "HomeSlidingMenuViewController.h"
#import "ServerManager.h"
#import "CuratedPhotoModel.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface HomeSlidingMenuViewController ()


@end

@implementation HomeSlidingMenuViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self request];
    NSLog(@"HomeSlidingMenuViewController");
    
    //self.collectionView.prefetchingEnabled = false;
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    self.collectionView.delegate = self;
    // Register cell classes
    
    // Do any additional setup after loading the view.
}



- (NSInteger)numberOfItemsInSlidingMenu {
    return [self.curatedPhotoArray count]; // 10 menu items
}

- (void)customizeCell:(RPSlidingMenuCell *)slidingMenuCell forRow:(NSInteger)row {
    
    CuratedPhotoModel *model = [self.curatedPhotoArray objectAtIndex:row];
    
    slidingMenuCell.textLabel.text = model.photoPhotographer;
    slidingMenuCell.detailTextLabel.text = @"Some longer description that is like a subtitle!";
    [slidingMenuCell.backgroundImageView sd_setImageWithURL:[model.photoSrc valueForKey:@"medium"]];
    
}

- (void)slidingMenu:(RPSlidingMenuViewController *)slidingMenu didSelectItemAtRow:(NSInteger)row {
    // when a row is tapped do some action like go to another view controller
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Row Tapped"
                                                    message:[NSString stringWithFormat:@"Row %d tapped.", row]
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)request {
    
    [[ServerManager sharedManager] getCuratedPhotosPer_page:40
                                                       page:1
                                                  onSuccess:^(NSArray *photos) {
        
                                                      for (int i = 0; i < [photos count]; i++) {
                                                        NSArray *array = [photos objectAtIndex:i];
                                                        CuratedPhotoModel *model = [[CuratedPhotoModel alloc] init];
                                                          
                                                          model.photoHeight       = [array valueForKey:@"height"];
                                                          model.photoWidth        = [array valueForKey:@"width"];
                                                          model.photoPhotographer = [array valueForKey:@"photographer"];
                                                          model.photoId           = [array valueForKey:@"id"];
                                                          model.photoUrl          = [array valueForKey:@"url"];
                                                          model.photoSrc          = [array valueForKey:@"src"];
                                                          [self.curatedPhotoArray addObject:model];
                                                                                     }
                                                      [self.collectionView reloadData];
    }
                                                  onFailure:^(NSError *error, NSInteger statusCode) {
                                                      
    }];
    
    
}

@end
