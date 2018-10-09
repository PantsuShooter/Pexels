//
//  HomeCollectionViewController.m
//  Pexels
//
//  Created by Цындрин Антон on 09.08.2018.
//  Copyright © 2018 Цындрин Антон. All rights reserved.
//

#import "HomeCollectionViewController.h"
#import "CuratedPhotoModel.h"
#import "ServerManager.h"
#import "HomeCollectionViewCell.h"
#import "CustomViewActionController.h"
#import "FavoriteManager.h"

//*Pods
#import <SDWebImage/UIImageView+WebCache.h>
#import <UIScrollView+SVPullToRefresh.h>
#import <UIScrollView+SVInfiniteScrolling.h>
#import <RMActionController.h>
#import "RKDropdownAlert.h"

#import <AFNetworking.h>

@interface HomeCollectionViewController ()
@property (weak, nonatomic) IBOutlet UILabel *nowIsLoadingLable;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *nowIsLoadingIndicator;

@property(strong,nonatomic)NSMutableArray        *curatedPhotoArray;
@property(assign,nonatomic)__block NSInteger       page;
@property(assign,nonatomic)__block NSInteger       loadingNowPhotos;
@property(strong,nonatomic)CuratedPhotoModel     *selectedModel;

@end

@implementation HomeCollectionViewController

static NSString * const reuseIdentifier = @"homeCell";

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self request];
    [self setup];
    [self addInfiniteScrolling];
}

- (void)setup {
    self.curatedPhotoArray = [[NSMutableArray alloc] init];
    self.loadingNowPhotos = 0;
    self.collectionView.alwaysBounceVertical = NO;
    self.nowIsLoadingIndicator.hidesWhenStopped = YES;
    self.nowIsLoadingLable.hidden = YES;
    
}

- (void)addInfiniteScrolling
{

    self.page = 1;
    __weak HomeCollectionViewController *weakSelf = self;
    
    [self.collectionView addInfiniteScrollingWithActionHandler:^{
        NSLog(@"HomeCollectionViewController| addInfiniteScrollingWithActionHandler");
        weakSelf.page = weakSelf.page + 1;
        [weakSelf request];
    }];
}

#pragma mark - <UICollectionViewDataSource>
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.curatedPhotoArray count];
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat sizeW = self.collectionView.frame.size.width;
    CGFloat lableSize = self.collectionView.frame.size.height / 15  + 20;
    
    return CGSizeMake(sizeW,sizeW + lableSize);
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    HomeCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    CuratedPhotoModel *model = [self.curatedPhotoArray objectAtIndex:indexPath.row];
        
        NSURL *url = [NSURL URLWithString:[model.photoSrc valueForKey:@"square"]];
        [cell.photoImageView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"Placeholder"]];
        cell.photographerLable.text = model.photoPhotographer;
        NSLog(@"HomeCollectionViewController| Cell init  %ld",(long)indexPath.row + 1);
        NSLog(@"HomeCollectionViewController| Objects in array  %lu",(unsigned long)[self.curatedPhotoArray count]);
        [cell.photographerLable setFont:[UIFont systemFontOfSize:17.f]];
    
    if (indexPath.row == [self.curatedPhotoArray count] - 20) {
        [self.collectionView.infiniteScrollingView stopAnimating];
    }

    return cell;
}

#pragma mark - <UICollectionViewDelegate>
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    self.selectedModel = [self.curatedPhotoArray objectAtIndex:indexPath.row];
    NSLog(@"HomeCollectionViewController| Cell selected %ld",(long)indexPath.row);
    [self sheetSetupAndCall];
}

#pragma mark - sheetSetupAndCall
- (void)sheetSetupAndCall {
    
    __weak HomeCollectionViewController *weakSelf = self;
    
    //*setup sheet button's
    RMAction *shareAction = [RMAction<UIView *> actionWithTitle:@"Share" style:RMActionStyleCancel andHandler:^(RMActionController<UIView *> *controller) {
        
        NSLog(@"HomeCollectionViewController| shareAction");
        NSURL *url = [NSURL URLWithString:[self.selectedModel.photoSrc valueForKey:@"original"]];
        NSArray *array = [NSArray arrayWithObject:url];
        UIActivityViewController* activityViewController =[[UIActivityViewController alloc] initWithActivityItems:array applicationActivities:nil];
        [self presentViewController:activityViewController animated:YES completion:^{}];
    }];
  

    RMAction *likeAction = [RMAction<UIView *> actionWithTitle:@"Favorite" style:RMActionStyleCancel andHandler:^(RMActionController<UIView *> *controller) {
        
        NSLog(@"HomeCollectionViewController| likeActiond");
        [[FavoriteManager favoriteManager] addToArraySelectedModel:self.selectedModel];
    }];
    
    
    RMAction *saveAction = [RMAction<UIView *> actionWithTitle:@"Save" style:RMActionStyleCancel andHandler:^(RMActionController<UIView *> *controller) {
        
        NSLog(@"HomeCollectionViewController| saveAction");

        //*
        weakSelf.loadingNowPhotos = weakSelf.loadingNowPhotos + 1;
        [self photoLoadingLable];
        if (weakSelf.loadingNowPhotos > 0) {
            weakSelf.nowIsLoadingLable.hidden = NO;
            [weakSelf.nowIsLoadingIndicator startAnimating];
        }
    
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        [queue addOperationWithBlock:^{
       
            NSURL *url = [NSURL URLWithString:[self.selectedModel.photoSrc valueForKey:@"original"]];
            NSData *data = [NSData dataWithContentsOfURL:url];
            UIImage *image = [UIImage imageWithData:data];
            UIImageWriteToSavedPhotosAlbum(image, self,nil, nil);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
            NSString *alertString = [NSString stringWithFormat:@"Photo taken by '%@' successfully saved.",self.selectedModel.photoPhotographer];
            [self alertWithTitleString:@"Success!" andmassageString:alertString];
               weakSelf.loadingNowPhotos = weakSelf.loadingNowPhotos - 1;
                
                [self photoLoadingLable];
                
                if (weakSelf.loadingNowPhotos == 0) {
                    weakSelf.nowIsLoadingLable.hidden = YES;
                    [weakSelf.nowIsLoadingIndicator stopAnimating];
                }
            });
        }];
    }];
    
    
    RMAction *cancelAction = [RMAction<UIView *> actionWithTitle:@"Cancel" style:RMActionStyleCancel andHandler:^(RMActionController<UIView *> *controller) {
        NSLog(@"HomeCollectionViewController| cancelAction");
    }];
    
    
    NSArray *array = [NSArray arrayWithObjects:saveAction,likeAction,shareAction,nil];
    RMGroupedAction *groupedAction = [RMGroupedAction<UIView *> actionWithStyle:RMActionStyleDestructive andActions:array];
    
    RMActionControllerStyle style = RMActionControllerStyleBlack;
    CustomViewActionController *actionController = [CustomViewActionController actionControllerWithStyle:style];
    actionController.title = @"Options";
    //actionController.message = nil;
    
    [actionController addAction:groupedAction];
    [actionController addAction:cancelAction];
    
    [self presentActionController:actionController];
}

//*Lable set singular or plural
- (void)photoLoadingLable {
    
    __weak HomeCollectionViewController *weakSelf = self;
    
    if (weakSelf.loadingNowPhotos == 1) {
        self.nowIsLoadingLable.text = [NSString stringWithFormat:@"Loading %ld photo",(long)weakSelf.loadingNowPhotos];
    }else{
        self.nowIsLoadingLable.text = [NSString stringWithFormat:@"Loading %ld photos",(long)weakSelf.loadingNowPhotos];
    }
}

//*Alert setup
- (void)alertWithTitleString:(NSString*)titleString andmassageString:(NSString*)massageString{
    [RKDropdownAlert title:titleString message:massageString backgroundColor:[UIColor blackColor] textColor:[UIColor orangeColor] time:2.0f delegate:nil];
    
}

//*Present Action Controller
- (void)presentActionController:(RMActionController *)actionController {

    if([actionController respondsToSelector:@selector(popoverPresentationController)] && [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        
        actionController.modalPresentationStyle = UIModalPresentationPopover;
    }
    
    [self presentViewController:actionController animated:YES completion:nil];
}

//*Request
#pragma mark - request
- (void)request {
    
    [[ServerManager sharedManager] getCuratedPhotosPerPage:40
                                                       page:self.page
                                                  onSuccess:^(NSArray *photos) {
                                                      
                                                      for (int i = 0; i < [photos count]; i++) {
                                                          NSArray *array = [photos objectAtIndex:i];
                                                          CuratedPhotoModel *model = [[CuratedPhotoModel alloc] init];
                                                          
                                                          NSNumber *photoHeightNuber         = [array valueForKey:@"height"];
                                                          NSString *photoHeight   = [photoHeightNuber stringValue];
                                                          model.photoHeight       = [photoHeight doubleValue];
                                                          
                                                          NSNumber *photoWidthNuber         = [array valueForKey:@"width"];
                                                          NSString *photoWidth    = [photoWidthNuber stringValue];
                                                          model.photoWidth        = [photoWidth doubleValue];
                                                          
                                                          NSNumber *photoIdNuber  = [array valueForKey:@"id"];
                                                          NSString *photoId       = [photoIdNuber stringValue];
                                                          model.photoId           = photoId;
                                                          
                                                          model.photoPhotographer = [array valueForKey:@"photographer"];
                                                          model.photoUrl          = [array valueForKey:@"url"];
                                                          model.photoSrc          = [array valueForKey:@"src"];
                                                          [self.curatedPhotoArray addObject:model];
                                                          
                                                      }
                                                      [self.collectionView reloadData];
                                                  }
                                                  onFailure:^(NSError *error, NSInteger statusCode) {
                                                      
                                                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                                          [self request];
                                                      });
                                                      
                                                  }];
}

@end
