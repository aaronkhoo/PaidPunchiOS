//
//  PunchCompleteViewController.m
//  paidPunch
//
//  Created by Aaron Khoo on 2/5/13.
//  Copyright (c) 2013 PaidPunch. All rights reserved.
//

#include "CommonDefinitions.h"
#import "AppDelegate.h"
#import "PunchCard.h"
#import "PunchCompleteViewController.h"
#import "Utilities.h"

@interface PunchCompleteViewController ()
{
    PunchCard* _punchcard;
}
@end

@implementation PunchCompleteViewController

- (id)initWithPunchcard:(PunchCard *)current
{
    self = [super init];
    if (self)
    {
        _punchcard = current;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self createMainView:[UIColor whiteColor]];
    
    [self createSilverBackgroundWithImage];
    
    [self createBanners];
    
    [self createLabels];
    
    [self createDoneButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - private functions

- (void)createBanners
{
    UIImageView* banner = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"graybanner.png"]];
    banner.frame = [Utilities resizeProportionally:banner.frame maxWidth:stdiPhoneWidth maxHeight:stdiPhoneHeight];
    [_mainView addSubview:banner];
    
    UILabel* textLabel = [[UILabel alloc] initWithFrame:banner.frame];
    textLabel.backgroundColor = [UIColor clearColor];
    textLabel.textColor = [UIColor whiteColor];
    textLabel.textAlignment = UITextAlignmentCenter;
    textLabel.text = @"Show Phone To Cashier";
    [textLabel setAdjustsFontSizeToFitWidth:YES];
    [_mainView addSubview:textLabel];
    
    UIImageView* ppBanner = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"l.png"]];
    CGRect finalRect = [Utilities resizeProportionally:ppBanner.frame maxWidth:stdiPhoneWidth maxHeight:stdiPhoneHeight];
    finalRect.origin.y = banner.frame.size.height + 20;
    ppBanner.frame = finalRect;
    [_mainView addSubview:ppBanner];
    
    _lowestYPos = ppBanner.frame.size.height + ppBanner.frame.origin.y;
}

- (void) createLabels
{
    CGFloat gapsBetweenLabels = 20;
    
    // Name of business
    UIFont* bizFont = [UIFont fontWithName:@"Helvetica-Bold" size:20.0f];
    UILabel* bizLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, _lowestYPos + gapsBetweenLabels, stdiPhoneWidth, 60)];
    bizLabel.backgroundColor = [UIColor clearColor];
    bizLabel.textColor = [UIColor blackColor];
    bizLabel.textAlignment = UITextAlignmentCenter;
    bizLabel.text = [_punchcard business_name];
    [bizLabel setAdjustsFontSizeToFitWidth:YES];
    [bizLabel setFont:bizFont];
    [_mainView addSubview:bizLabel];
    _lowestYPos = bizLabel.frame.size.height + bizLabel.frame.origin.y;
    
    // terms
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle: NSNumberFormatterCurrencyStyle];
    UIFont* termsFont = [UIFont fontWithName:@"Helvetica-Bold" size:20.0f];
    UILabel* termsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, _lowestYPos + gapsBetweenLabels, stdiPhoneWidth, 60)];
    termsLabel.backgroundColor = [UIColor clearColor];
    termsLabel.textColor = [UIColor orangeColor];
    termsLabel.textAlignment = UITextAlignmentCenter;
    termsLabel.text = [NSString stringWithFormat:@"%@ off purchase of\n %@ or more", [numberFormatter stringFromNumber:[_punchcard each_punch_value]], [numberFormatter stringFromNumber:[_punchcard minimum_value]]];
    [termsLabel setAdjustsFontSizeToFitWidth:YES];
    [termsLabel setNumberOfLines:2];
    [termsLabel setFont:termsFont];
    [_mainView addSubview:termsLabel];
    _lowestYPos = termsLabel.frame.size.height + termsLabel.frame.origin.y;
    
    // TODO: Add Code if necessary
    
    // condition
    UIFont* conditionFont = [UIFont fontWithName:@"Helvetica" size:14.0f];
    UILabel* conditionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, _lowestYPos + gapsBetweenLabels, stdiPhoneWidth, 60)];
    conditionLabel.backgroundColor = [UIColor clearColor];
    conditionLabel.textColor = [UIColor blackColor];
    conditionLabel.textAlignment = UITextAlignmentCenter;
    conditionLabel.text = @"Cannot be used in combination with\n other coupons or discounts";
    [conditionLabel setAdjustsFontSizeToFitWidth:YES];
    [conditionLabel setFont:conditionFont];
    [conditionLabel setNumberOfLines:2];
    [_mainView addSubview:conditionLabel];
    _lowestYPos = conditionLabel.frame.size.height + conditionLabel.frame.origin.y;
}

- (void)createDoneButton
{
    UIFont* textFont = [UIFont fontWithName:@"Helvetica-Bold" size:17.0f];
    NSString* couponText = @"Done";
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"green-suggest-button" ofType:@"png"];
    NSData *imageData = [NSData dataWithContentsOfFile:filePath];
    UIImage *image = [[UIImage alloc] initWithData:imageData];
    UIButton* doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    CGRect originalRect = CGRectMake(0, 0, image.size.width, image.size.height);
    CGRect finalRect = [Utilities resizeProportionally:originalRect maxWidth:(stdiPhoneWidth - 60) maxHeight:stdiPhoneHeight];
    finalRect.origin.x = (stdiPhoneWidth - finalRect.size.width)/2;
    finalRect.origin.y = stdiPhoneHeight - (finalRect.size.height + 50);
    
    doneButton.frame = finalRect;
    [doneButton setBackgroundImage:image forState:UIControlStateNormal];
    [doneButton setTitle:couponText forState:UIControlStateNormal];
    [doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    doneButton.titleLabel.font = textFont;
    [doneButton addTarget:self action:@selector(didPressDoneButton:) forControlEvents:UIControlEventTouchUpInside];
    
    [_mainView addSubview:doneButton];
}

#pragma mark - event actions

- (void) didPressDoneButton:(id)sender
{
    //[self.navigationController popToRootViewControllerAnimated:NO];
    AppDelegate *delegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate initView];
}

@end