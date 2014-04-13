//
//  WLULoginViewController.h
//  WLUExams
//
//  Created by Erin Cramer on 2014-04-09.
//  Copyright (c) 2014 Erin Cramer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WLULoginViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *imgWLU;
@property (weak, nonatomic) IBOutlet UITextField *txtEmail;
@property (weak, nonatomic) IBOutlet UITextField *txtPassword;
- (IBAction)registerUser:(id)sender;
- (IBAction)login:(id)sender;
@property NSMutableData *receivedData;
@property NSURLConnection *connection;
@property (weak, nonatomic) IBOutlet UILabel *lblMessage;

@end
