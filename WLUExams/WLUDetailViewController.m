//
//  WLUDetailViewController.m
//  WLUExams
//
//  Created by Erin Cramer on 2014-04-09.
//  Copyright (c) 2014 Erin Cramer. All rights reserved.
//

#import "WLUDetailViewController.h"
#import "WLUExam.h"
#import "WLUAnnotation.h"
#import "KeychainItemWrapper.h"
#import "WLUMasterViewController.h"
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>

@implementation WLUDetailViewController


- (void)configureView
{
    
    [self getUserExam];
    self.navigationItem.title = self.exam.courseCode;
    self.txtCourseCode.text = [NSString stringWithFormat:@"%@ %@",self.exam.courseCode, self.exam.section];
    self.txtLocation.text = [NSString stringWithFormat:@"%@, %@",self.exam.location, self.exam.room];
    
    NSDate *date = self.exam.date;
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"MMMM d, yyyy 'at' h:mm a"];
    NSString *formattedDateString = [formatter stringFromDate:date];
    [self.btnDateTime setTitle:formattedDateString forState:UIControlStateNormal];
    
    
    //figure out map
    if(![self.exam.location isEqualToString:@"Online"]){
        
        self.map.scrollEnabled = YES;
        self.map.zoomEnabled = YES;
        
        CLLocationCoordinate2D coord;
        coord.longitude = self.exam.longitude;
        coord.latitude = self.exam.latitude;
        
        MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(coord, 250, 250);
        MKCoordinateRegion adjustedRegion = [self.map regionThatFits:viewRegion];
        [self.map setRegion:adjustedRegion animated:YES];
        
        WLUAnnotation *ann = [[WLUAnnotation alloc] initWithCoordinate:coord];
        [self.map addAnnotation:ann];
        
    }
    
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureView];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

- (void) getUserExam {
    

    NSString *link = @"http://hopper.wlu.ca/~wluexams/php/Users/Exams/check.php";
    
    [self connectToDB:link];
    
}



- (void)connection:(NSURLConnection
                    *)connection didReceiveResponse:
(NSURLResponse *)response {
    
    [_receivedData setLength:0];
    
}

- (void)connection:(NSURLConnection *)connection
    didReceiveData:(NSData *)data {
    
    [_receivedData appendData:data];
    
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error{
    
    _connection = nil; // release the connection
    _receivedData = nil;
    
    
}

- (void)connectionDidFinishLoading:
(NSURLConnection *)connection
{
    [self parseCheckJSON];
    _connection = nil;
    _receivedData = nil;
    
}

- (void) parseCheckJSON {
    
    
    NSError *jsonError = nil;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:_receivedData options:kNilOptions error:&jsonError];
    
    if ([jsonObject isKindOfClass:[NSDictionary class]]) {
        
        NSDictionary *jsonDictionary = (NSDictionary *)jsonObject;
        NSString *response = [jsonDictionary objectForKey:@"response"];
        
        if ([response isEqualToString:@"true"]){
            
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(removeExamFromUser)];
            
        } else {
            
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveExam)];
            
        }
        
        
    }
    
}


-(void) removeExamFromUser {
    

    NSString *link = @"http://hopper.wlu.ca/~wluexams/php/Users/Exams/remove.php";
    
    [self connectToDB:link];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveExam)];
    
}

-(void) connectToDB:(NSString *)link {
    
    KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:@"WLUExamUser" accessGroup:nil];
    NSString *userID = [keychainItem objectForKey:(__bridge id)(kSecAttrAccount)];
    NSString *examID = [[NSString alloc] initWithFormat:@"%i",self.exam.examID];
    NSString *bodyData = [NSString stringWithFormat: @"userID=%@&examID=%@", userID, examID];
    
    _receivedData = [NSMutableData dataWithCapacity: 0];
    
    NSMutableURLRequest *request = [NSMutableURLRequest
                                    
                                    requestWithURL:[NSURL URLWithString:link]];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[NSData dataWithBytes:[bodyData UTF8String] length:strlen([bodyData UTF8String])]];
    
    
    _connection=[[NSURLConnection alloc]
                 initWithRequest:request delegate:self];
    
}

- (void) saveExam {

    NSString *link = @"http://hopper.wlu.ca/~wluexams/php/Users/Exams/add.php";
    
    [self connectToDB:link];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(removeExamFromUser)];
    
}

- (IBAction)addEventToCal:(id)sender {
    
    EKEventStore *eventStore = [[EKEventStore alloc] init];
    
    if([eventStore respondsToSelector:@selector(requestAccessToEntityType:completion:)]) {
        [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
            
            EKEvent *event = [EKEvent eventWithEventStore:eventStore];
            
            event.title= [[NSString alloc] initWithFormat:@"%@ Exam",self.exam.courseCode];
            event.location = self.exam.location;
            
            NSDate *eventDate = self.exam.date;
            event.startDate = eventDate;
            event.endDate= [[NSDate alloc] initWithTimeInterval:7200 sinceDate:eventDate];
            
            NSTimeInterval interval = 60* -15;
            EKAlarm *alarm = [EKAlarm alarmWithRelativeOffset:interval];
            [event addAlarm:alarm];
            
            EKEventEditViewController *controller = [[EKEventEditViewController alloc] init];
            controller.eventStore       = eventStore;
            controller.event            = event;
            controller.editViewDelegate = self;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self presentViewController:controller animated:YES completion:NULL];
                
            });
            
        }];
    }
    


    
}

-(void)eventEditViewController:(EKEventEditViewController *)controller
         didCompleteWithAction:(EKEventEditViewAction)action {
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
