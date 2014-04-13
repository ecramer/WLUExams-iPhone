//
//  WLULoginViewController.m
//  WLUExams
//
//  Created by Erin Cramer on 2014-04-09.
//  Copyright (c) 2014 Erin Cramer. All rights reserved.
//

#import "WLULoginViewController.h"
#import "KeychainItemWrapper.h"


@implementation WLULoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];

}

-(void)viewDidAppear:(BOOL)animated {
    
    KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:@"WLUExamUser" accessGroup:nil];
    NSString *userID = [keychainItem objectForKey:(__bridge id)(kSecAttrAccount)];
    NSString *userString = [[NSString alloc] initWithFormat:@"%@", userID];
    
    if (![userString isEqualToString:@""]) {
        
        [self performSegueWithIdentifier:@"authenticated" sender:self];
        
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)authenticate:(NSString *)link {
    
    NSString *email = self.txtEmail.text;
    NSString *password = self.txtPassword.text;
    
    if ([email length] == 0 || [password length] == 0) {
        
        self.lblMessage.text = @"Email and password cannot be empty.";
        
    } else {
        
        NSString *bodyData = [NSString stringWithFormat: @"email=%@&password=%@", email, password];
        
        // Create the NSMutableData to hold the received data.
        // receivedData is an instance variable declared elsewhere.
        _receivedData = [NSMutableData dataWithCapacity: 0];
        
        // create the connection with the request
        // and start loading the data
        NSMutableURLRequest *request = [NSMutableURLRequest
                                        
                                        requestWithURL:[NSURL URLWithString:link]];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:[NSData dataWithBytes:[bodyData UTF8String] length:strlen([bodyData UTF8String])]];
        
        
        _connection=[[NSURLConnection alloc]
                     initWithRequest:request delegate:self];
        
    }
    
    
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
    [self parseJSON];
    _connection = nil;
    _receivedData = nil;
    
}

- (void) parseJSON {
    
    
    NSError *jsonError = nil;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:_receivedData options:kNilOptions error:&jsonError];
    NSDictionary *jsonDictionary = (NSDictionary *)jsonObject;
    
    if([jsonDictionary objectForKey:@"id"] == nil){
        
        NSString *message = [jsonDictionary objectForKey:@"error"];
        self.lblMessage.text = message;
        
    } else {
        
        //we're good
        KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:@"WLUExamUser" accessGroup:nil];
        NSString *userID = [jsonDictionary objectForKey:@"id"];
        [keychainItem setObject:userID forKey:(__bridge id)(kSecAttrAccount)];
        [self performSegueWithIdentifier:@"authenticated" sender:self];
        
    }
    
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [self.txtEmail resignFirstResponder];
    [self.txtPassword resignFirstResponder];
    
}



- (IBAction)registerUser:(id)sender {
    
    NSString *url = [[NSMutableString alloc] initWithString: @"http://hopper.wlu.ca/~cram8680/php/Users/add.php"];
    [self authenticate:url];
    
}

- (IBAction)login:(id)sender {
    
    NSString *url = [[NSMutableString alloc] initWithString: @"http://hopper.wlu.ca/~cram8680/php/Users/authenticate.php"];
    [self authenticate:url];
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self animateTextField: textField up: NO];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self animateTextField: textField up: YES];
}

- (void) animateTextField: (UITextField*) textField up: (BOOL) up
{
    const int movementDistance = 90; // tweak as needed
    const float movementDuration = 0.3f; // tweak as needed
    
    int movement = (up ? -movementDistance : movementDistance);
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
}

@end
