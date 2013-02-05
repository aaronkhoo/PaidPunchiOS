//
//  MyCouponsView.m
//  paidPunch
//
//  Created by Aaron Khoo on 2/1/13.
//  Copyright (c) 2013 PaidPunch. All rights reserved.
//

#include "CommonDefinitions.h"
#import "MyCouponsView.h"
#import "Punches.h"

@implementation MyCouponsView
@synthesize controller = _controller;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _lowestYPos = 0;
        
        [self createMyCouponsLabel];
        
        // Initializing punch cards retrieval
        _networkManager=[[NetworkManager alloc] initWithView:self];
        _networkManager.delegate=self;
        
        if ([[Punches getInstance] needsRefresh])
        {
            _hud = [MBProgressHUD showHUDAddedTo:self animated:YES];
            _hud.labelText = @"Retrieving Punches";
            
            [[DatabaseManager sharedInstance] deleteMyPunches];
            [self getMyPunches];
        }
        else
        {
            [self createCouponsTable];
        }
    }
    return self;
}

#pragma mark - private functions

- (void)createMyCouponsLabel
{
    CGFloat myCouponsLabelHeight = 30;
    UILabel* myCouponsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _popupView.frame.size.width, myCouponsLabelHeight)];
    myCouponsLabel.text = @"My Coupons";
    [myCouponsLabel setFont:[UIFont fontWithName:@"Arial-BoldMT" size:17.0f]];
    [myCouponsLabel setTextAlignment:UITextAlignmentCenter];
    [myCouponsLabel setBackgroundColor:[UIColor blackColor]];
    [myCouponsLabel setTextColor:[UIColor whiteColor]];
    [_popupView addSubview:myCouponsLabel];
    _lowestYPos = myCouponsLabelHeight;
}

- (void)createCouponsTable
{
    // create a scrollview
    CGRect myCouponsRect = CGRectMake(0, _lowestYPos, _popupView.frame.size.width, _popupView.frame.size.height - _lowestYPos);
    _myCouponsScrollView = [[UIScrollView alloc] initWithFrame:myCouponsRect];
    _myCouponsScrollView.backgroundColor = [UIColor clearColor];
    [_myCouponsScrollView setContentOffset:CGPointMake(0.0, 0.0) animated:YES];
	_myCouponsScrollView.scrollEnabled = FALSE;
    _myCouponsScrollView.contentSize = CGSizeMake(_popupView.frame.size.width, stdiPhoneHeight);
    [_popupView addSubview:_myCouponsScrollView];
    
    _myCouponsTable = [[MyCouponsTableView alloc] initWithFrame:CGRectMake(0, 0, _popupView.frame.size.width, _popupView.frame.size.height)];
    [_myCouponsTable setController:_controller];
    [_myCouponsScrollView addSubview:_myCouponsTable];
}

-(void)getMyPunches
{
    [_networkManager getUserPunches:[[User getInstance] userId]];
}

#pragma mark - network manager delegate
-(void) didFinishGetUsersPunch:(NSString*)statusCode
{
    [[DatabaseManager sharedInstance] saveEntity:nil];
    NSArray *arr=[[DatabaseManager sharedInstance] fetchPunchCards];
    [[Punches getInstance] setPunchesArray:arr];
    [[Punches getInstance] updateDate];
    [self createCouponsTable];
    [MBProgressHUD hideHUDForView:self animated:NO];
}

@end
