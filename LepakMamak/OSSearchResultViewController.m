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
    static NSString *cellId = @"RestaurantCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
        
    }
    cell.textLabel.text = [object valueForKey:kOSRestaurantNameKey];
   // cell.detailTextLabel.text = [object valueForKey:@"updated_at"];
    return cell;
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

@end
