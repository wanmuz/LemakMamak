//
//  OSViewController.m
//  LepakMamak
//
//  Created by Azad Johari on 9/15/13.
//  Copyright (c) 2013 Wan Muzaffar. All rights reserved.
//

#import "OSViewController.h"
#import "OSDetailViewController.h"
@interface OSViewController ()

@end

@implementation OSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (![PFUser currentUser] ){
        [self setLoginPage];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)setLoginPage{
    OSLoginViewController *loginViewController = [[OSLoginViewController alloc] init];
    [loginViewController setDelegate:self];
    [loginViewController setFacebookPermissions:[NSArray arrayWithObjects:@"friends_about_me", nil]];
    [loginViewController setFields:PFLogInFieldsUsernameAndPassword | PFLogInFieldsTwitter | PFLogInFieldsSignUpButton | PFLogInFieldsDismissButton];
    [self presentViewController:loginViewController animated:YES completion:nil];
    
    }

#pragma mark - Parse

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    
    // This method is called every time objects are loaded from Parse via the PFQuery
}

- (void)objectsWillLoad {
    [super objectsWillLoad];
    
    // This method is called before a PFQuery is fired to get more objects
}


-(PFQuery*)queryForTable{
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    if ([self.objects count] == 0){
        query.cachePolicy= kPFCachePolicyCacheThenNetwork;
    }
    [query orderByAscending:@"name"];
    return query;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    static NSString *CellIdentifier = @"restaurantCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell
    cell.textLabel.text = [object objectForKey:@"name"];
    cell.detailTextLabel.text = [object objectForKey:@"address"];
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
@end
