//
//  WLUAnnotation.h
//  WLUExams
//
//  Created by Erin Cramer on 2014-04-10.
//  Copyright (c) 2014 Erin Cramer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface WLUAnnotation : NSObject<MKAnnotation> {
    
    CLLocationCoordinate2D coordinate;
    
}

- (id) initWithCoordinate:(CLLocationCoordinate2D)c;
    

@end
