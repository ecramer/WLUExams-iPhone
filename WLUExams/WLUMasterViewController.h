//
//  WLUMasterViewController.h
//  WLUExams
//
//  Created by Erin Cramer on 2014-04-09.
//  Copyright (c) 2014 Erin Cramer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WLUMasterViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnLogout;
- (IBAction)logoutUser:(id)sender;
@property NSMutableArray *exams;
@property NSMutableData *receivedData;
@property NSURLConnection *connection;
-(void)getUserExams;
@property UIBarButtonItem *addExam;

@end
