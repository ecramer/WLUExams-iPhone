//
//  WLUMasterViewController.m
//  WLUExams
//
//  Created by Erin Cramer on 2014-04-09.
//  Copyright (c) 2014 Erin Cramer. All rights reserved.
//

#import "WLUMasterViewController.h"
#import "WLUExam.h"
#import "WLUDetailViewController.h"
#import "KeychainItemWrapper.h"


@implementation WLUMasterViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.addExam = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(goToAddExams)];
    UIBarButtonItem *editExam = self.editButtonItem;

    self.navigationItem.rightBarButtonItems = @[self.addExam, editExam];
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        WLUExam *exam = [self.exams objectAtIndex:indexPath.row];
        [self removeExamFromUser:exam];
        [self.exams removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    
}


-(void)goToAddExams {
    
    [self performSegueWithIdentifier:@"addExams" sender:self];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:YES];
    if (editing) {
        self.addExam.enabled = NO;
        self.btnLogout.enabled = NO;
    } else {
        self.addExam.enabled = YES;
        self.btnLogout.enabled = YES;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return self.exams.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    WLUExam *exam = self.exams[indexPath.row];
    NSString *courseString = [NSString stringWithFormat: @"%@ %@", [exam courseCode], [exam section]];
    cell.textLabel.text = courseString;
    return cell;
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    self.exams = [[NSMutableArray alloc]init];
    [self getUserExams];
    [self.tableView reloadData];
}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        WLUExam *exam = self.exams[indexPath.row];
        [[segue destinationViewController] setExam:exam];
        
    }
}

- (void) getUserExams {
    
    KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:@"WLUExamUser" accessGroup:nil];
    NSString *userID = [keychainItem objectForKey:(__bridge id)(kSecAttrAccount)];
    NSString *bodyData = [NSString stringWithFormat: @"userID=%@", userID];
    NSString *link = @"http://hopper.wlu.ca/~cram8680/php/Users/Exams/list.php";

    [self connectToDB:link bodyData:bodyData];
    
}

-(void) connectToDB: (NSString *)link bodyData:(NSString *)bodyData {
    
    _receivedData = [NSMutableData dataWithCapacity: 0];
    
    NSMutableURLRequest *request = [NSMutableURLRequest
                                    
                                    requestWithURL:[NSURL URLWithString:link]];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[NSData dataWithBytes:[bodyData UTF8String] length:strlen([bodyData UTF8String])]];
    
    
    _connection=[[NSURLConnection alloc]
                 initWithRequest:request delegate:self];
    
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

-(void) removeExamFromUser:(WLUExam *)exam {
    
    KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:@"WLUExamUser" accessGroup:nil];
    NSString *userID = [keychainItem objectForKey:(__bridge id)(kSecAttrAccount)];
    NSString *bodyData = [NSString stringWithFormat: @"userID=%@&examID=%i", userID, exam.examID];
    
    NSString *link = @"http://hopper.wlu.ca/~wluexams/php/Users/Exams/remove.php";
    
    [self connectToDB:link bodyData:bodyData];
    
}


- (void) parseJSON {
    
    
    NSError *jsonError = nil;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:_receivedData options:kNilOptions error:&jsonError];
    
    if ([jsonObject isKindOfClass:[NSArray class]]) {

        NSArray *jsonArray = (NSArray *)jsonObject;
        for(NSDictionary *jsonDictionary in jsonArray) {
            
            WLUExam *exam = [[WLUExam alloc]init];
            
            exam.examID = [[jsonDictionary objectForKey:@"ID"]intValue];
            exam.courseCode = [jsonDictionary objectForKey:@"courseID"];
            exam.section = [jsonDictionary objectForKey:@"section"];
            exam.location = [jsonDictionary objectForKey:@"location"];
            exam.room = [jsonDictionary objectForKey:@"room"];
            exam.department = [jsonDictionary objectForKey:@"depName"];
            
            NSString *strDate = [jsonDictionary objectForKey:@"date"];
            NSString *strTime = [jsonDictionary objectForKey:@"time"];
            
            NSString *strDateTime = [[NSString alloc] initWithFormat:@"%@ %@", strDate, strTime];
            NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
            [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"EST"]];
            
            exam.date = [formatter dateFromString:strDateTime];
            
            
            if (![exam.location isEqualToString:@"Online"]){
                
                exam.latitude = [[jsonDictionary objectForKey:@"lat"]floatValue];
                exam.longitude = [[jsonDictionary objectForKey:@"long"]floatValue];
                
            }
            
            [self.exams addObject:exam];
            
        }
        
            [self.tableView reloadData];
        
    } else {

        //no exams saved

    }
    
    
}

- (IBAction)logoutUser:(id)sender {
    
    KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:@"WLUExamUser" accessGroup:nil];
    [keychainItem resetKeychainItem];
    [self performSegueWithIdentifier:@"logout" sender:self];
    
}
@end
