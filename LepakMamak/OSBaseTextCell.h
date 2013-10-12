//
//  OSBaseTextCell.h
//  LepakMamak
//
//  Created by Azad Johari on 10/12/13.
//  Copyright (c) 2013 Wan Muzaffar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
@interface OSBaseTextCell : UITableViewCell

@property (nonatomic, strong) PFUser *user;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *userAvatar;


- (void)setDate:(NSDate *)date;;
@end
