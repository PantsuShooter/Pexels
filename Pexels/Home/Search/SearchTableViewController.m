//
//  SearchTableViewController.m
//  Pexels
//
//  Created by Цындрин Антон on 31.08.2018.
//  Copyright © 2018 Цындрин Антон. All rights reserved.
//

#import "SearchTableViewController.h"
#import "ServerManager.h"
#import "CuratedPhotoModel.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <MMParallaxCell.h>
#import <UIScrollView+SVInfiniteScrolling.h>
#import <NYTPhotosViewController.h>
#import "PhotoVieweModel.h"
#import "FavoriteManager.h"
#import "RKDropdownAlert.h"
#import <MONActivityIndicatorView.h>


@interface SearchTableViewController () <NYTPhotosViewControllerDelegate,MONActivityIndicatorViewDelegate>

@property(strong,nonatomic)NSMutableArray        *curatedPhotoArray;
@property(assign,nonatomic)__block NSInteger       page;

@property(strong,nonatomic)CuratedPhotoModel     *selectedModel;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property(strong,nonatomic)NYTPhotosViewController *photosViewController;
@property(strong,nonatomic)MONActivityIndicatorView *indicatorView;

@end

@implementation SearchTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.curatedPhotoArray = [[NSMutableArray alloc] init];
    [self.tableView setSeparatorColor:[UIColor blackColor]];
    [self addInfiniteScrolling];
    [self gesture];
    [self activityIndicator];
    
    
}

- (void)activityIndicator {

    self.indicatorView = [[MONActivityIndicatorView alloc] init];
    self.indicatorView.delegate = self;
    self.indicatorView.translatesAutoresizingMaskIntoConstraints = false;
    
    
    [self.tableView addSubview:self.indicatorView];
    [self placeAtTheCenterWithView:self.indicatorView];
}

- (void)placeAtTheCenterWithView:(UIView *)view {
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0f
                                                           constant:0.0f]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                          attribute:NSLayoutAttributeCenterY
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterY
                                                         multiplier:1.0f
                                                           constant:0.0f]];
}


- (UIColor *)activityIndicatorView:(MONActivityIndicatorView *)activityIndicatorView
      circleBackgroundColorAtIndex:(NSUInteger)index{
    
    CGFloat red   = (arc4random() % 256)/255.0;
    CGFloat green = (arc4random() % 256)/255.0;
    CGFloat blue  = (arc4random() % 256)/255.0;
    CGFloat alpha = 1.0f;
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

- (void)gesture {
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    gestureRecognizer.cancelsTouchesInView = NO;
    [self.tableView addGestureRecognizer:gestureRecognizer];
}

- (void)hideKeyboard {
    [self.tableView endEditing:YES];
}

- (void)tableViewBackground:(UIImage*) image{

    UIImageView *tempImageView = [[UIImageView alloc] initWithImage:image];
    tempImageView.contentMode = UIViewContentModeScaleAspectFit;
    [tempImageView setFrame:self.tableView.frame];
    self.tableView.backgroundView = tempImageView;
}



- (void)addInfiniteScrolling
{
    
    self.page = 1;
    __weak SearchTableViewController *weakSelf = self;

    [self.tableView addInfiniteScrollingWithActionHandler:^{
        NSLog(@"SearchTableViewController| addInfiniteScrollingWithActionHandler");
        weakSelf.page = weakSelf.page + 1;
        [weakSelf request];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.curatedPhotoArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat sizeW = self.tableView.frame.size.width;
    return sizeW;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MMParallaxCell *cell = [tableView dequeueReusableCellWithIdentifier:@"searchCell" forIndexPath:indexPath];
    
    CuratedPhotoModel *model = [self.curatedPhotoArray objectAtIndex:indexPath.row];
    
    NSURL *url = [NSURL URLWithString:[model.photoSrc valueForKey:@"square"]];
    [cell.parallaxImage sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"Placeholder"]];

    NSLog(@"HomeCollectionViewController| Cell init  %ld",(long)indexPath.row + 1);
    
    if (indexPath.row == [self.curatedPhotoArray count] - 20) {
        [self.tableView.infiniteScrollingView stopAnimating];
        NSLog(@"SearchTableViewController| addInfiniteScrollingWithActionHandler indexPath.row %ldl",(long)indexPath.row);

    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    self.selectedModel = [self.curatedPhotoArray objectAtIndex:indexPath.row];
    NSLog(@"SearchTableViewController| Cell selected %ld",(long)indexPath.row);
    

    PhotoVieweModel *selectedSearchModel = [[PhotoVieweModel alloc] init];
    selectedSearchModel.placeholderImage = [UIImage imageNamed:@"Placeholder"];
    
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    NSBlockOperation *operationObj = [NSBlockOperation blockOperationWithBlock:^{
    NSURL *url = [NSURL URLWithString:[self.selectedModel.photoSrc valueForKey:@"original"]];
    NSData *data = [NSData dataWithContentsOfURL:url];
    
    selectedSearchModel.image = [UIImage imageWithData:data];
    }];
    [operationObj setCompletionBlock:^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.photosViewController updateImageForPhoto:selectedSearchModel];
        });
    }];
    
    [queue addOperation: operationObj];
    
    NSString *titleString = [NSString stringWithFormat:@"Photo was taken by '%@'.",self.selectedModel.photoPhotographer];
    
    NSAttributedString *captionTitle = [[NSAttributedString alloc] initWithString:titleString attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleBody]}];
    
    selectedSearchModel.attributedCaptionTitle = captionTitle;
    
    NSArray*array = [NSArray arrayWithObject:selectedSearchModel];
    
    self.photosViewController = [[NYTPhotosViewController alloc]initWithPhotos:array];
    self.photosViewController.underStatusBar = YES;
    
    
    UIBarButtonItem *shareButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareAction)];
    
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"saveBarButton"] style:UIBarButtonItemStylePlain target:self action:@selector(saveAction)];
    
    UIBarButtonItem *favoriteButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"starBarButton"] style:UIBarButtonItemStylePlain target:self action:@selector(favoriteAction)];
    
    self.photosViewController.rightBarButtonItems = [NSArray arrayWithObjects:saveButton,shareButton,favoriteButton, nil];
    
    [self presentViewController:self.photosViewController animated:YES completion:nil];
    NSLog(@"SearchTableViewController|didSelectItemAtIndexPath %@",indexPath);
    
}

- (void)shareAction {
    
    NSLog(@"SearchTableViewController| shareAction");
    
    NSURL *url = [NSURL URLWithString:[self.selectedModel.photoSrc valueForKey:@"original"]];
    NSArray *array = [NSArray arrayWithObject:url];
    UIActivityViewController* activityViewController =[[UIActivityViewController alloc] initWithActivityItems:array applicationActivities:nil];
    [self.photosViewController presentViewController:activityViewController animated:YES completion:^{}];
}

- (void)favoriteAction {
    NSLog(@"favoriteAction");
    [[FavoriteManager favoriteManager] addToArraySelectedModel:self.selectedModel];
}

- (void)saveAction {
    NSLog(@"saveAction");
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperationWithBlock:^{
        
        NSURL *url = [NSURL URLWithString:[self.selectedModel.photoSrc valueForKey:@"original"]];
        NSData *data = [NSData dataWithContentsOfURL:url];
        UIImage *image = [UIImage imageWithData:data];
        UIImageWriteToSavedPhotosAlbum(image, self,nil, nil);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSString *alertString = [NSString stringWithFormat:@"Photo taken by '%@' successfully saved.",self.selectedModel.photoPhotographer];
            [self alertWithTitleString:@"Success!" andmassageString:alertString];
            
        });
    }];
    
}

- (void)alertWithTitleString:(NSString*)titleString andmassageString:(NSString*)massageString{
    [RKDropdownAlert title:titleString message:massageString backgroundColor:[UIColor blackColor] textColor:[UIColor orangeColor] time:2.0f delegate:nil];
    
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    [self.curatedPhotoArray removeAllObjects];
    [self request];
    [self.indicatorView startAnimating];
}

- (void)request {
    [[ServerManager sharedManager] getSearchPhotoUseQuery:self.searchBar.text
                                                 per_page:40
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
                                    
                                                    if ([photos count] == 0) {
                                                        [self.tableView setSeparatorColor:[UIColor clearColor]];
                                                        [self tableViewBackground:[UIImage imageNamed:@"404.1.png"]];
                                                        [self.indicatorView stopAnimating];
                                                        [self.tableView reloadData];
                                                    }else{
                                                        [self.tableView setSeparatorColor:[UIColor blackColor]];
                                                        self.tableView.backgroundView = nil;
                                                        [self.indicatorView stopAnimating];
                                                        [self.tableView reloadData];
                                                    }
                                                } onFailure:^(NSError *error, NSInteger statusCode) {
       
                                                   
    } ];
    
    
}

@end
