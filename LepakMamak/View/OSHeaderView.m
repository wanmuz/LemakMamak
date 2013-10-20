//
//  OSHeaderView.m
//  LepakMamak
//
//  Created by Azad Johari on 9/17/13.
//  Copyright (c) 2013 Wan Muzaffar. All rights reserved.
//

#import "OSHeaderView.h"

@implementation OSHeaderView

@synthesize likeButton;
@synthesize delegate;
@synthesize restaurant;
@synthesize nameLabel;
@synthesize addressLabel;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
- (id)initWithRestaurant:(PFObject*)aRestaurant
{
    self = [super init];
    if (self) {
        self.restaurant = aRestaurant;
        // Initialization code
    }
    return self;
}
+ (CGRect)rectForView {
    return CGRectMake( 0.0f, 0.0f, [UIScreen mainScreen].bounds.size.width, 100.0f);
}
-(void)setRestaurant:(PFObject *)aRestaurant{
    self.nameLabel.text = [aRestaurant objectForKey:@"name"];
    self.addressLabel.text = [aRestaurant objectForKey:@"address"];
    [self.likeButton addTarget:self action:@selector(didTapLikeRestaurantButtonAction:) forControlEvents:UIControlEventTouchUpInside];

}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
-(void)setLikeStatus:(BOOL)liked{
    [self.likeButton setSelected:liked];
    if(liked){
        [self.likeButton setTitle:@"You have Liked!" forState:UIControlStateNormal];
    }else{
         [self.likeButton setTitle:@"Unliked!" forState:UIControlStateNormal];
    }
}
-(void)didTapLikeRestaurantButtonAction:(UIButton*)button{
    if (delegate && [delegate respondsToSelector:@selector(headerView:didTapLikeRestaurantButton:restaurant:)]) {
        [delegate headerView:self didTapLikeRestaurantButton:button restaurant:self.restaurant];
}
}
-(void)didTapFavRestaurantButtonAction:(UIButton*)button{
    if(delegate && [delegate respondsToSelector:@selector(headerView:didTapFavRestaurantButton:restaurant:)]){
        [delegate headerView:self didTapFavRestaurantButton:button restaurant:self.restaurant];
    }
}
@end
