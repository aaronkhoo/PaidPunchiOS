//
//  BusinessLocationAnnotation.m
//  paidPunch
//
//  Created by mobimedia technologies on 26/04/12.
//  Copyright (c) 2012 mobimedia. All rights reserved.
//

#import "BusinessLocationAnnotation.h"

@implementation BusinessLocationAnnotation

@synthesize latitude = _latitude;
@synthesize longitude = _longitude;

- (id)initWithLatitude:(CLLocationDegrees)latitude
		  andLongitude:(CLLocationDegrees)longitude {
	if (self = [super init]) {
		self.latitude = latitude;
		self.longitude = longitude;
	}
	return self;
}

- (CLLocationCoordinate2D)coordinate {
	CLLocationCoordinate2D coordinate;
	coordinate.latitude = self.latitude;
	coordinate.longitude = self.longitude;
	return coordinate;
}

@end
