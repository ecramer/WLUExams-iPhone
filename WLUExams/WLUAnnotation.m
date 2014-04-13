//
//  WLUAnnotation.m
//  WLUExams
//
//  Created by Erin Cramer on 2014-04-10.
//  Copyright (c) 2014 Erin Cramer. All rights reserved.
//

#import "WLUAnnotation.h"

@implementation WLUAnnotation

@synthesize coordinate;

-(id)initWithCoordinate:(CLLocationCoordinate2D)c {
    
    coordinate = c;
    return self;
    
}

@end
