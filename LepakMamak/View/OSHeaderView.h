//
//  OSHeaderView.h
//  LepakMamak
//
//  Created by Azad Johari on 9/17/13.
//  Copyright (c) 2013 Wan Muzaffar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
@class OSHeaderView;
@protocol OSHeaderViewDelegate<NSObject>;
@optional

- (void)headerView:(OSHeaderView *)headerView didTapLikeRestaurantButton:(UIButton *)button restaurant:(PFObject *)restaurant;
- (void)headerView:(OSHeaderView *)headerView didTapFavRestaurantButton:(UIButton *)button restaurant:(PFObject *)restaurant;
@end
@interface OSHeaderView : UIView

@property (nonatomic, strong) PFObject *restaurant;
@property (nonatomic,readonly) IBOutlet UIButton *likeButton;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *addressLabel;
@property (nonatomic, strong) id<OSHeaderViewDelegate> delegate;
- (id)initWithRestaurant:(PFObject*)aRestaurant;
+ (CGRect)rectForView;
-(void)setLikeStatus:(BOOL)liked;
@end


