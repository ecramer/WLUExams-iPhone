//
//  WLUDetailViewController.h
//  WLUExams
//
//  Created by Erin Cramer on 2014-04-09.
//  Copyright (c) 2014 Erin Cramer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <EventKitUI/EventKitUI.h>

@class WLUExam;
@interface WLUDetailViewController : UIViewController <EKEventEditViewDelegate>

@property WLUExam *exam;
@property (weak, nonatomic) IBOutlet UILabel *txtCourseCode;
@property (weak, nonatomic) IBOutlet UILabel *txtLocation;
@property (weak, nonatomic) IBOutlet MKMapView *map;
@property NSMutableData *receivedData;
@property NSURLConnection *connection;
@property (weak, nonatomic) IBOutlet UIButton *btnDateTime;
- (IBAction)addEventToCal:(id)sender;

@end
