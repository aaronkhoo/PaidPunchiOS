//
//  MyCouponsTableView.m
//  paidPunch
//
//  Created by Aaron Khoo on 2/1/13.
//  Copyright (c) 2013 PaidPunch. All rights reserved.
//

#include "CommonDefinitions.h"
#import "MyCouponsTableView.h"
#import "MyCouponViewController.h"
#import "PunchCard.h"
#import "Punches.h"

static CGFloat const kAmountSize = 100.0;
static CGFloat const kCellHeight = 60.0;

@implementation MyCouponsTableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.dataSource = self;
        self.delegate = self;
        _currentPunchcards = [[Punches getInstance] validPunchesArray];
        [self setRowHeight:kCellHeight];
        [self setBackgroundColor:[UIColor whiteColor]];
    }
    return self;
}

#pragma mark UITableViewDataSource methods Implementation

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_currentPunchcards count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    
    PunchCard* currentPunchcard = [_currentPunchcards objectAtIndex:indexPath.row];
    UILabel* nameLabel = [self createNameLabel:currentPunchcard.punch_card_name];
    [cell addSubview:nameLabel];
    
    // Create amount label
    UIFont* textFont = [UIFont fontWithName:@"Helvetica-Bold" size:18.0f];
    UILabel* amountLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width - kAmountSize, 5, kAmountSize - 10  , kCellHeight)];
    amountLabel.text = [currentPunchcard getRemainingAmountAsString];
    amountLabel.backgroundColor = [UIColor clearColor];
    amountLabel.textColor = [UIColor colorWithRed:0.0f green:153.0f/255.0f blue:51.0f/255.0f alpha:1.0f];
    [amountLabel setNumberOfLines:1];
    [amountLabel setFont:textFont];
    amountLabel.textAlignment = UITextAlignmentRight;
    [cell addSubview:amountLabel];
    
   	return cell;
}

- (UILabel*)createNameLabel:(NSString*)name
{
    CGFloat maxWidth = self.frame.size.width - kAmountSize;
    float startingSize = 18.0f;
    UIFont* textFont = [UIFont fontWithName:@"Helvetica" size:startingSize];
    UILabel* newLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, maxWidth, kCellHeight)];
    newLabel.text = name;
    newLabel.backgroundColor = [UIColor clearColor];
    newLabel.textColor = [UIColor blackColor];
    [newLabel setNumberOfLines:2];
    [newLabel setFont:textFont];
    [newLabel setAdjustsFontSizeToFitWidth:TRUE];
    newLabel.textAlignment = UITextAlignmentLeft;
    
    return newLabel;
}

#pragma mark UITableViewDelegate methods Implementation

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PunchCard* current = [_currentPunchcards objectAtIndex:indexPath.row];
    [self goToPunchView:current];
    [self deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark -

-(void) goToPunchView:(PunchCard *)punchCard
{
    MyCouponViewController* myCoupon = [[MyCouponViewController alloc] initWithPunchcard:punchCard];
    AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    UINavigationController* nav = appDelegate.navigationController;
    [nav pushViewController:myCoupon animated:NO];
}
@end
