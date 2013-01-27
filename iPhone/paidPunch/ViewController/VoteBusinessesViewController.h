//
//  VoteBusinessesViewController.h
//  paidPunch
//
//  Created by Aaron Khoo on 1/25/13.
//  Copyright (c) 2013 PaidPunch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseWithNavBarViewController.h"
#import "HttpCallbackDelegate.h"
#import "MBProgressHUD.h"

@interface VoteBusinessesViewController : BaseWithNavBarViewController<HttpCallbackDelegate>
{
    MBProgressHUD* _hud;
}

@end
