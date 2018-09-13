//
//  FavoriteCollectionViewController.m
//  Pexels
//
//  Created by Цындрин Антон on 12.08.2018.
//  Copyright © 2018 Цындрин Антон. All rights reserved.
//

#import "FavoriteCollectionViewController.h"
#import "FavoriteCollectionViewCell.h"
#import "CuratedPhotoModel.h"
#import "FavoriteManager.h"

#import <NYTPhotosViewController.h>
#import "PhotoVieweModel.h"

#import <SDWebImage/UIImageView+WebCache.h>

#import "FavoritePhotoModel+CoreDataClass.h"
#import "FavoritePhotoSrc+CoreDataClass.h"

#import "RKDropdownAlert.h"

#import <JBWebViewController/JBWebViewController.h>

@interface FavoriteCollectionViewController ()

@property(strong,nonatomic)NSMutableArray* favorite;
@property(strong,nonatomic)FavoritePhotoModel     *favoritePhotoModel;
@property(strong,nonatomic)NYTPhotosViewController *photosViewController;


@end

@implementation FavoriteCollectionViewController

static NSString * const reuseIdentifier = @"favoriteCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
     self.favorite = [[NSMutableArray alloc] init];
    
    NSLog(@"HomeCollectionViewController| self.favorite count %lu",(unsigned long)[self.favorite count]);
    
    NSLog(@"FavoriteCollectionViewController| viewDidLoad");
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
   // [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    // Do any additional setup after loading the view.
    
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.extendedLayoutIncludesOpaqueBars = NO;
    self.automaticallyAdjustsScrollViewInsets = NO;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.favorite = [[NSMutableArray alloc] init];
    [self.favorite addObjectsFromArray:[[FavoriteManager favoriteManager] getArraryWithSelectedModel]];
    [self.collectionView reloadData];
    
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat sizeW = self.collectionView.frame.size.width;
    
    CGFloat cellSize = sizeW / 3;
    CGFloat inset = 15;
    
    return CGSizeMake(cellSize - inset, cellSize - inset);
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {

    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

    return [self.favorite count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FavoriteCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    FavoritePhotoModel *model = [self.favorite objectAtIndex:indexPath.row];
    FavoritePhotoSrc *src = [[FavoritePhotoSrc alloc] init];
    
    src = model.favoritePhotoSrc;
    
    NSURL *url = [NSURL URLWithString:src.favoriteSquare];
    [cell.favoriteImageView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"Placeholder"]];
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    self.favoritePhotoModel = [self.favorite objectAtIndex:indexPath.row];
    FavoritePhotoSrc *src = [[FavoritePhotoSrc alloc] init];
    src = self.favoritePhotoModel.favoritePhotoSrc;
    
    
    NSLog(@"SearchTableViewController| Cell selected %ld",(long)indexPath.row);
    
    PhotoVieweModel *selectedSearchModel = [[PhotoVieweModel alloc] init];
    selectedSearchModel.placeholderImage = [UIImage imageNamed:@"Placeholder"];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    NSBlockOperation *operationObj = [NSBlockOperation blockOperationWithBlock:^{
        NSURL *url = [NSURL URLWithString:src.favoriteOriginal];
        NSData *data = [NSData dataWithContentsOfURL:url];
        
        selectedSearchModel.image = [UIImage imageWithData:data];
    
    }];
    [operationObj setCompletionBlock:^{

        dispatch_async(dispatch_get_main_queue(), ^{
        [self.photosViewController updateImageForPhoto:selectedSearchModel];
        });
    }];
    
    [queue addOperation: operationObj];
    
    
    NSString *titleString = [NSString stringWithFormat:@"Photo was taken by '%@'.",self.favoritePhotoModel.favoritePhotoPhotographer];
    
    NSAttributedString *captionTitle = [[NSAttributedString alloc] initWithString:titleString attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleBody]}];
    
    selectedSearchModel.attributedCaptionTitle = captionTitle;
    
    NSArray*array = [NSArray arrayWithObject:selectedSearchModel];
    
    self.photosViewController = [[NYTPhotosViewController alloc]initWithPhotos:array];
    self.photosViewController.underStatusBar = YES;
    
    
    UIBarButtonItem *shareButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareAction)];
    
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"saveBarButton"] style:UIBarButtonItemStylePlain target:self action:@selector(saveAction)];
    
    UIBarButtonItem *showInternetPageButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"safari"] style:UIBarButtonItemStylePlain target:self action:@selector(showInternetPageAction)];
    
    self.photosViewController.rightBarButtonItems = [NSArray arrayWithObjects:saveButton,shareButton,showInternetPageButton, nil];
    
    [self presentViewController:self.photosViewController animated:YES completion:nil];
    NSLog(@"SearchTableViewController|didSelectItemAtIndexPath %@",indexPath);
    
}



- (void)shareAction {
    
    NSLog(@"SearchTableViewController| shareAction");
    
    FavoritePhotoSrc *src = [[FavoritePhotoSrc alloc] init];
    src = self.favoritePhotoModel.favoritePhotoSrc;
    
    NSURL *url = [NSURL URLWithString:src.favoriteOriginal];
    NSArray *array = [NSArray arrayWithObject:url];
    UIActivityViewController* activityViewController =[[UIActivityViewController alloc] initWithActivityItems:array applicationActivities:nil];
    [self.photosViewController presentViewController:activityViewController animated:YES completion:^{}];
}

- (void)showInternetPageAction {
    NSLog(@"showInternetPage");
    
    JBWebViewController *controller = [[JBWebViewController alloc] initWithUrl:[NSURL URLWithString:self.favoritePhotoModel.favoritePhotoUrl]];
    
    [controller showFromController:self.presentedViewController];
    
}

- (void)saveAction {
    NSLog(@"saveAction");
    
    FavoritePhotoSrc *src = [[FavoritePhotoSrc alloc] init];
    src = self.favoritePhotoModel.favoritePhotoSrc;
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperationWithBlock:^{
        
        NSURL *url = [NSURL URLWithString:src.favoriteOriginal];
        NSData *data = [NSData dataWithContentsOfURL:url];
        UIImage *image = [UIImage imageWithData:data];
        UIImageWriteToSavedPhotosAlbum(image, self,nil, nil);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSString *alertString = [NSString stringWithFormat:@"Photo taken by '%@' successfully saved.",self.favoritePhotoModel.favoritePhotoPhotographer];
            [self alertWithTitleString:@"Success!" andmassageString:alertString];
            
        });
    }];
    
}

- (void)alertWithTitleString:(NSString*)titleString andmassageString:(NSString*)massageString{
    [RKDropdownAlert title:titleString message:massageString backgroundColor:[UIColor blackColor] textColor:[UIColor orangeColor] time:2.0f delegate:nil];
    
}
    

@end
