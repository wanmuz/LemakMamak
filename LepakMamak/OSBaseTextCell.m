//
//  OSBaseTextCell.m
//  LepakMamak
//
//  Created by Azad Johari on 10/12/13.
//  Copyright (c) 2013 Wan Muzaffar. All rights reserved.
//

#import "OSBaseTextCell.h"
#import "TTTTimeIntervalFormatter.h"

static TTTTimeIntervalFormatter *timeFormatter;
@implementation OSBaseTextCell
@synthesize user;
-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self){
        if (!timeFormatter){
            timeFormatter = [[TTTTimeIntervalFormatter alloc] init];
        }
        // Initialization code

    }
    return self;
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        if (!timeFormatter){
        timeFormatter = [[TTTTimeIntervalFormatter alloc] init];
    }
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)setUser:(PFUser *)aUser{
    user = aUser;
    [self.nameLabel setText:[self.user objectForKey:@"username"]];
}
-(void)setDate:(NSDate *)date{
   [self.timeLabel setText:[timeFormatter stringForTimeIntervalFromDate:[NSDate date] toDate:date]];
   
    [self setNeedsDisplay];
}
@end
