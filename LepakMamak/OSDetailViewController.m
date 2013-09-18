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
    
    //Set table header
    
    self.headerView.restaurant = restaurant;
    headerView.delegate = self;
    
    [ self.headerView.likeButton setTitle:[[[OSCache sharedCache] likeCountForRestaurant:restaurant] description]forState:UIControlStateNormal];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object{
    static NSString *cellId = @"CommentCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
        
            }
cell.textLabel.text = [object valueForKey:kOSPActivityContentKey];
cell.detailTextLabel.text = [object valueForKey:@"updated_at"];
    return cell;
}

#pragma mark - PFQueryTableViewController

-(PFQuery *)queryForTable{
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    [query whereKey:kOSActivityRestaurantKey equalTo:self.restaurant];
    [query includeKey:kOSPActivityFromUserKey];
    [query whereKey:kOSActivityTypeKey equalTo:kOSActivityTypeComment];
    [query orderByAscending:@"createdAt"];
    
    if (self.objects.count == 0 || ![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]) {
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
    NSLog(@"button clicked");
    BOOL liked = !button.selected;
   // [headerView setLikesStatus:liked];
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_us"]];
    
    NSNumber *likeCount = [numberFormatter numberFromString:button.titleLabel.text];
    
  //  if (liked){
    likeCount = [NSNumber numberWithInt:[likeCount intValue]+ 1];
    [[OSCache sharedCache] incrementLikerCountForRestaurant:restaurant];
    
    [[OSUtility sharedInstance] likeRestaurantInBackground:restaurant block:^(BOOL succeeded, NSError *error){
        
    }];
   // }
}
@end