//
//  OSDetailViewController.m
//  LepakMamak
//
//  Created by Azad Johari on 9/15/13.
//  Copyright (c) 2013 Wan Muzaffar. All rights reserved.
//

#import "OSDetailViewController.h"
#import "OSConstants.h"
#import "MBProgressHUD.h"
@interface OSDetailViewController ()
@property (nonatomic, strong) IBOutlet OSHeaderView *headerView;
@property (nonatomic, strong) NSArray *restaurantImageInfos;
@end

@implementation OSDetailViewController
@synthesize restaurant, headerView;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"bar"] forBarMetrics:UIBarMetricsDefault];
    //Set table header
    self.restaurantImageInfos=[[NSMutableArray alloc] initWithObjects:[UIImage imageNamed:@"placeholder.jpg"], nil];
    self.imagePager.indicatorDisabled=YES;
    self.headerView.restaurant = restaurant;
    headerView.delegate = self;
    NSDictionary *attributesForRestau = [[OSCache sharedCache] attributesForRestaurant:restaurant];
    if (attributesForRestau){
        [headerView setLikeStatus:[[OSCache sharedCache] isRestaurantLikedByCurrentUser:restaurant]];
        [headerView.likeButton setTitle:[[[OSCache sharedCache] likeCountForRestaurant:restaurant] description] forState:UIControlStateNormal];
    }else{
        
        PFQuery *query = [[OSUtility sharedInstance] queryForActivitiesOnRestaurant:restaurant cachePolicy:kPFCachePolicyNetworkOnly];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError* error){
        
            if (error) {
                return;
            }
            NSMutableArray *likers = [NSMutableArray array];
            NSMutableArray *commenters = [NSMutableArray array];
            
            BOOL isLikedByCurrentUser = NO;
            
            for (PFObject *activity in objects){
                if ([[activity objectForKey:kOSActivityTypeKey] isEqualToString:kOSActivityTypeLike] && [activity objectForKey:kOSPActivityFromUserKey]){
                    [likers addObject:kOSPActivityFromUserKey];
                }else if([[activity objectForKey:kOSActivityTypeKey] isEqualToString:kOSActivityTypeComment] && [activity objectForKey:kOSPActivityFromUserKey]){
                    [commenters addObject:kOSPActivityFromUserKey];
                }
            if ([[[activity objectForKey:kOSPActivityFromUserKey] objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
                if ([[activity objectForKey:kOSActivityTypeKey] isEqualToString:kOSActivityTypeLike]) {
                    isLikedByCurrentUser = YES;
                }
            }
            }
            [[OSCache sharedCache] setAttributesForRestaurant:restaurant
                                                 likers:likers commenters:commenters likedByCurrentUser:isLikedByCurrentUser];
        }];
        
    
        }
     [self getRestaurantImages];
    [ self.headerView.likeButton setTitle:[[[OSCache sharedCache] likeCountForRestaurant:restaurant] description]forState:UIControlStateNormal];
	// Do any additional setup after loading the view.
}
-(void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    _imagePager.pageControl.currentPageIndicatorTintColor = [UIColor lightGrayColor];
    _imagePager.pageControl.pageIndicatorTintColor = [UIColor blackColor];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)getRestaurantImages{
    PFQuery *query = [PFQuery queryWithClassName:kOSPhotoClassKey];
    [query whereKey:kOSPhotoUserKey equalTo:[PFUser currentUser]];
     [query whereKey:kOSPhotoRestaurantKey equalTo:self.restaurant];
   [query findObjectsInBackgroundWithBlock:^(NSArray *obj, NSError *error){
       if(!error){
           if ([obj count]>0){
           NSMutableArray *arrayTemp = [[NSMutableArray alloc] init];
               for (PFObject *object in obj)
               {
                   PFFile *tempFile=[object objectForKey:kOSPhotoPictureKey ];
                   [arrayTemp addObject:tempFile.url];
               }
           self.restaurantImageInfos=arrayTemp;
           self.imagePager.indicatorDisabled=NO;
           [self.imagePager reloadData];
           }
       }
    }];
    
}
-(UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object{
    static NSString *cellId = @"CommentCell";
    OSBaseTextCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil){
        cell = [[OSBaseTextCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        
            }
    [cell setUser:[object objectForKey:kOSPActivityFromUserKey]];
  //  cell.nameLabel.text = [[object valueForKey:kOSPActivityFromUserKey] valueForKey:@"name"];
cell.commentLabel.text = [object valueForKey:kOSPActivityContentKey];
    [cell setDate:[object createdAt]];
    return cell;
}
#pragma mark - KIImagePager DataSource
- (NSArray *) arrayWithImages
{
    return self.restaurantImageInfos;
    
}
- (UIViewContentMode) contentModeForImage:(NSUInteger)image
{
    return UIViewContentModeScaleAspectFill;
}
#pragma mark - PFQueryTableViewController

-(PFQuery *)queryForTable{
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    [query whereKey:kOSActivityRestaurantKey equalTo:self.restaurant];
    [query includeKey:kOSPActivityFromUserKey];
    [query whereKey:kOSActivityTypeKey equalTo:kOSActivityTypeComment];
    [query orderByAscending:@"createdAt"];
    
  //  if (self.objects.count == 0 || ![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]) {
    if (self.objects.count == 0){
        [query setCachePolicy:kPFCachePolicyCacheThenNetwork];
    }
    
    return query;
}
#pragma mark - 
#pragma mark - UITextFieldDelegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    NSString *trimmedComment = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (trimmedComment.length != 0 ){
        PFObject *comment = [PFObject objectWithClassName:kOSActivityClassKey];
        [comment setObject:trimmedComment forKey:kOSPActivityContentKey];
        [comment setObject:[PFUser currentUser] forKey:kOSPActivityFromUserKey];
        [comment setObject:kOSActivityTypeComment forKey:kOSActivityTypeKey];
        [comment setObject:self.restaurant forKey:kOSActivityRestaurantKey];
        
        PFACL *ACL = [PFACL ACLWithUser:[PFUser currentUser]];
        [ACL setPublicReadAccess:YES];
        comment.ACL = ACL;
        
        [MBProgressHUD showHUDAddedTo:self.view.superview animated:YES];
        
        [comment saveEventually:^(BOOL succeeded, NSError *error){
            if (!error){
                [MBProgressHUD hideHUDForView:self.view.superview animated:YES];
                [self loadObjects];
            }
        
        }];
    }
}
-(void)headerView:(OSHeaderView *)headerView didTapLikeRestaurantButton:(UIButton *)button restaurant:(PFObject *)aRestaurant{
   
    BOOL liked = !button.selected;
   // [headerView setLikeStatus:liked];
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_us"]];
    
    NSNumber *likeCount = [numberFormatter numberFromString:button.titleLabel.text];
    
    if (liked){
    likeCount = [NSNumber numberWithInt:[likeCount intValue]+ 1];
    [[OSCache sharedCache] incrementLikerCountForRestaurant:restaurant];
    }
    else{
        if ([likeCount intValue] > 0){
            likeCount = [NSNumber numberWithInt:[likeCount intValue] - 1];
        }
        [[OSCache sharedCache] decrementLikerCountForRestaurant:restaurant];
    }
    [[OSCache sharedCache] setRestaurantIsLikedByCurrentUser:restaurant liked:liked];
    [button setTitle:[numberFormatter stringFromNumber:likeCount] forState:UIControlStateNormal];
    if (liked){
        [[OSUtility sharedInstance] likeRestaurantInBackground:restaurant block:^(BOOL succeeded, NSError *error){
            
        }];
    }else{
      [ [OSUtility sharedInstance] unlikeRestaurantInBackground:restaurant block:^(BOOL succeeded,
                                                                                   NSError* error){
        //  [self.headerView setLikeStatus:!succeeded];
      
       }];
    }
   // }
}

#pragma mark - ()

- (IBAction)cameraButtonPressed:(id)sender {
    BOOL cameraDeviceAvailable = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    BOOL photoLibraryAvailable = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary];
    if (cameraDeviceAvailable && photoLibraryAvailable){
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo", @"Choose photo",nil];
        [actionSheet showInView:self.view];
    }
}
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0){
        [self shouldStartCameraController];
    }else if (buttonIndex == 1){
        [self shouldStartPhotoLibraryPickerController];
    }
}
-(BOOL)shouldStartPhotoLibraryPickerController{
    if (([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] == NO && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO)){
        return NO;
    }
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] && [[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary] containsObject:(NSString*)kUTTypeImage]){
        cameraUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        cameraUI.mediaTypes = [NSArray arrayWithObject:(NSString*)kUTTypeImage];
    }else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum] && [[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum] containsObject:(NSString*)kUTTypeImage]){
        cameraUI.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        cameraUI.mediaTypes= [NSArray arrayWithObject:(NSString*)kUTTypeImage];
    }
    else{
        return NO;
    }
    cameraUI.allowsEditing = YES;
    cameraUI.delegate = self;
    [self presentViewController:cameraUI animated:YES completion:nil];
    return YES;
}
-(BOOL)shouldStartCameraController{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]== NO){
        return NO;
    }
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc]init];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] && [[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera] containsObject:(NSString*)kUTTypeImage]){
        cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
        cameraUI.mediaTypes = [NSArray arrayWithObject:(NSString*)kUTTypeImage];
        if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear]){
            cameraUI.cameraDevice = UIImagePickerControllerCameraDeviceRear;
        }else if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]){
            cameraUI.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        }
        
    }else{
        return NO;
    }
    cameraUI.allowsEditing = YES;
    cameraUI.showsCameraControls = YES;
    cameraUI.delegate = self;
    [self presentViewController:cameraUI animated:YES completion:nil];
    return YES;
}
#pragma mark - UIImagePickerDelegate

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    [self dismissViewControllerAnimated:YES completion:nil];
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    OSEditPhotoViewController *viewController = [[OSEditPhotoViewController alloc] initWithImage:image];
    viewController.restaurant = self.restaurant;
   // [self.navigationController setModalPresentationStyle:UIModalTransitionStyleCrossDissolve];
  //  [self.navigationController pushViewController:viewController animated:NO];
    [self.navigationController pushViewController:viewController animated:YES];
}
@end
