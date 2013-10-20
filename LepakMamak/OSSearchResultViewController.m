//
//  OSSearchResultViewController.m
//  LepakMamak
//
//  Created by Azad Johari on 9/23/13.
//  Copyright (c) 2013 Wan Muzaffar. All rights reserved.
//

#import "OSSearchResultViewController.h"

@interface OSSearchResultViewController ()

@end

@implementation OSSearchResultViewController
@synthesize restaurant,name, address, withWifi, screenExist;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(PFQuery*)queryForTable{
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    if ([self.objects count] == 0){
        query.cachePolicy= kPFCachePolicyCacheThenNetwork;
    }
    if (withWifi){
        [query whereKey:kOSRestaurantWithWifiKey equalTo:[NSNumber numberWithBool:TRUE]];
    }
    if (screenExist){
        [query whereKey:kOSRestaurantWithScreenKey equalTo:[NSNumber numberWithBool:TRUE]];
    }
    [query whereKey:kOSRestaurantNameKey containsString:name];
     [query whereKey:kOSRestaurantAddressKey containsString:address];
    [query includeKey:kOSPActivityFromUserKey];
    return query;
}

-(UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object{
    static NSString *cellId = @"MasterCell";
    MasterCell *cell = (MasterCell *)[tableView dequeueReusableCellWithIdentifier:cellId];
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    
    CALayer* shadow = [self createShadowWithFrame:CGRectMake(0, 67, 320, 5)];
    
    [cell.layer addSublayer:shadow];
    
    
    cell.titleLabel.text = [object objectForKey:@"name"];
    
   // cell.textLabel.text = [self getDistanceFromGeoPoint:[object objectForKey:@"location"]];;
    //object.tag = indexPath.row;
    return cell;
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([[segue identifier] isEqualToString:@"showDetail"]){
        OSDetailViewController *detailVC = [segue destinationViewController];
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        PFObject *restaurant = [self.objects objectAtIndex:indexPath.row];
        [detailVC setRestaurant:restaurant];
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 67;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(CALayer *)createShadowWithFrame:(CGRect)frame
{
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = frame;
    
    
    UIColor* lightColor = [[UIColor blackColor] colorWithAlphaComponent:0.0];
    UIColor* darkColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    
    gradient.colors = [NSArray arrayWithObjects:(id)darkColor.CGColor, (id)lightColor.CGColor, nil];
    
    return gradient;
}

@end
